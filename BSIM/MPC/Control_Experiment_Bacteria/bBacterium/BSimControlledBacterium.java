package bBacterium;

import java.util.Vector;

import javax.vecmath.Vector3d;


import bSolver.BSimEulerMaruyama;
import bsim.BSim;
import bsim.BSimChemicalField;
import bsim.capsule.BSimCapsuleBacterium;


/*********************************************************
 * Step 2: Extend BSimParticle as required and create vectors marked final
 * As an example let's make a bacteria that turns red upon colliding
 */		


public class BSimControlledBacterium extends BSimCapsuleBacterium {

	//definition of the internal dynamics
	protected BSimEulerMaruyama dyn;
	
	//external Inducers Fields
	protected BSimChemicalField AHLField;
	protected BSimChemicalField IPTGField;
	
	//current ODE variables
	public double[] y;
	public double[] y_fields; //It stores the old value to feed the field update (unless it overritten the old one and the field is fed with the next value)
	protected double[] yNew;
	private int nstate;
	
	//List of active bacteria
	private Vector<BSimControlledBacterium> bacteria;

	
	//Limit set to the bacteria population
	private int populationLimit;
	
	//Unique id of the bacterium
	static int curr_id=0;
	private int id;
	
	//Bacterium dynamics
	private BacteriumInternalDynDrift drift;
	public BacteriumInternalDynDiffusion diff;
	
	//Current simulation
	private BSim sim;

	
	public BSimControlledBacterium(BSim sim, Vector3d x1,Vector3d x2, BSimChemicalField fAHL, BSimChemicalField fIPTG,Vector<BSimControlledBacterium> bacteria,int populationLimit, int lacH) {
		super(sim, x1, x2);
		
		//I slow down the growth to make tha bacterium replicate about every 25 min
		this.k_growth=0.002;
		
		//Chemical fields initialization
		AHLField=fAHL;
		IPTGField=fIPTG;
		this.sim=sim;
		
		
		//Initialization of the dynamics
		drift = new BacteriumInternalDynDrift(lacH);
		diff= new BacteriumInternalDynDiffusion(lacH,sim);
		dyn= new BSimEulerMaruyama(drift,diff,sim.getDt()/60);
		
		
		//set the initial conditions
		nstate=drift.getNumEq();
		y = drift.getICs();
		y_fields=new double [nstate];
		for (int i=0;i<nstate;i++) {
			y_fields[i]=y[i];
		}
		
		//Set the other variables
		this.bacteria=bacteria;
		this.populationLimit=populationLimit;
		
		//Setting the ID
		id=curr_id;
		curr_id++;
		
		
	}
	
	@Override
	public void action() {
		
		// Movement (and growth/replication if growth rate > 0)
		super.action();
		
		// Drift External Fields Setting
		drift.setfaTc(AHLField.getConc(position));
		drift.setfIPTG(IPTGField.getConc(position));
		
		
		// Solve the SDE system
		// IMPORTANT: re-scale the time units correctly (Dyn equations are in minutes, BSim works in seconds)
		
		y_fields=y; //the current state value
		yNew = dyn.Euler_Maruyama(y, sim.getTime()/60);
		y = yNew; //the new state value
		
		
	}

	
	/*********************************************************
	 * Growth and replication.
	 */

	
	@Override
	public BSimControlledBacterium divide() {
		//CODE NOT MINE (BSIM CODE) to make the division 
		
		/*
        this           this    child
        x1 ->u x2  ->  x1  x2  x1  x2
        o------o       o---o | o---o
        */

        // TODO: refactor u into the main class. (As a method? Could then be up-to-date each time it is required...)
        // Total length is actually L + 2*r

        Vector3d u = new Vector3d(); u.sub(this.x2, this.x1);

        // Uniform Distn; Change to Normal?
        double divPert = 0.1*L_max*(rng.nextDouble() - 0.5);

        double L_actual = u.length();

        double L1 = L_actual*0.5*(1 + divPert) - radius;
        double L2 = L_actual*0.5*(1 - divPert) - radius;

        /// TODO::: Check that these are computed correctly...!
        Vector3d x2_new = new Vector3d();
        x2_new.scaleAdd(L1/L_actual, u, this.x1);
        x2_new.add(new Vector3d(0.05*L_initial*(rng.nextDouble() - 0.5),
                                0.05*L_initial*(rng.nextDouble() - 0.5),
                                0.05*L_initial*(rng.nextDouble() - 0.5)));

        Vector3d x1_child = new Vector3d();
        x1_child.scaleAdd(-(L2/L_actual), u, this.x2);
        x1_child.add(new Vector3d(0.05*L_initial*(rng.nextDouble() - 0.5),
                                  0.05*L_initial*(rng.nextDouble() - 0.5),
                                  0.05*L_initial*(rng.nextDouble() - 0.5)));

        /*
        This is dangerous.
        Ideally initialise all four co-ordinates, otherwise this operation is order-dependent
        (this.xi will be overwritten before being passed to child for ex.)
         */
        
        
        
        //I only changed this to initialize correctly the child
        BSimControlledBacterium child = new BSimControlledBacterium(sim,x1_child,new Vector3d(this.x2),AHLField,IPTGField,bacteria,populationLimit,0);
        //and its variables
        for (int i=0;i<nstate;i++) { //Whose fields have the same values of the mother (we can also set it at an half to simulate that all the material is equally distributed from one cell to another
			child.y[i]=this.y[i];
			child.y_fields[i]=this.y_fields[i];
		}
        //Initialize the child
        child.L = L2;
        child.initialise(L2, x1_child, this.x2);
        
        //Reinintialize the father
        this.initialise(L1, this.x1, x2_new);


        return child;
		
		
	}


	
	public int getId() {
		return id;
	}

	
	
	//To make the bacteria flow out both in the upper and the lower border
	@Override
    public void computeWallForce(){
//      System.out.println("Wall Force");

      // TODO::: Ideally, there should also be a bounds check on the side NEXT to the one from which bacs can exit
      /**
       * i.e.,
       *
       * open, flow - - - - - - - ->
       *            |            |  should have a bounds check here @ top so that bacs being pushed by the 'flow'
       *  closed    |            |  are allowed to continue moving right, above the RHS wall, rather than being
       *            .            .  *stopped* by the RHS bound check!
       *
       */
      wallBelow(x1.x, x1force, new Vector3d(1,0,0));
//      wallBelow(x1.y, x1force, new Vector3d(0,1,0)); // TOP // (IF I WANT THE CELLS TO EXIT ON THE TOP I HAVE TO COMMENT THIS LINE)
      wallBelow(x1.z, x1force, new Vector3d(0,0,1));

      wallAbove(x1.x, x1force, new Vector3d(-1, 0, 0), sim.getBound().x);

      wallAbove(x1.y, x1force, new Vector3d(0, -1, 0), sim.getBound().y); // BOTTOM //
      wallAbove(x1.z, x1force, new Vector3d(0, 0, -1), sim.getBound().z);

      wallBelow(x2.x, x2force, new Vector3d(1,0,0));
//      wallBelow(x2.y, x2force, new Vector3d(0,1,0)); // TOP // (IF I WANT THE CELLS TO EXIT ON THE TOP I HAVE TO COMMENT THIS LINE)
      wallBelow(x2.z, x2force, new Vector3d(0,0,1));

      wallAbove(x2.x, x2force, new Vector3d(-1,0,0), sim.getBound().x);

      wallAbove(x2.y, x2force, new Vector3d(0, -1, 0), sim.getBound().y); // BOTTOM //
      wallAbove(x2.z, x2force, new Vector3d(0, 0, -1), sim.getBound().z);
  }
  
	
	
}
