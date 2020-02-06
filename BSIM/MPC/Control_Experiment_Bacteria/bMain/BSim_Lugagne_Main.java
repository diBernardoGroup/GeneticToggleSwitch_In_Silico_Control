package bMain;
import bBacterium.BSimControlledBacterium;
import bControl.Controller;

import java.util.Random;
import java.util.Vector;

import javax.vecmath.Vector3d;

import bDrawer.ChamberDrawer;
import bDrawer.My3DDrawer;
import bField.ControlledFIeld;
import bLogger.*;
import bTicker.MyTicker;
import bsim.BSim;
import bsim.BSimChemicalField;
import bsim.BSimUtils;
import bsim.capsule.BSimCapsuleBacterium;
import bsim.draw.BSimDrawer;
import bsim.export.BSimLogger;
import bsim.export.BSimMovExporter;
import bsim.export.BSimPngExporter;

/**
 * An example simulation definition to illustrate the key features of a BSim model.</br>
 */
public class BSim_Lugagne_Main {

	public static void main(String[] args) {
		
		/**
		 * Step1: Initializing all the needed variables
		 */
		
		
		BSim sim = new BSim();			// New simulation object
		sim.setDt(1); //0.6				// Global dt (time step)
		sim.setSimulationTime(3*24*60*60);		// Total simulation time [sec]
		sim.setTimeFormat("0.00");		// Time format (for display etc.)
		sim.setBound(1.,30,1.);		// Simulation boundaries [um]
		sim.setSolid(true, false, true);  //To make the bacteria dont cross the borders
		
		
		//Control Parameters
		
		double aTcVal=35;
		double IPTGVal=0.35;
		double Ts=5;
		double Tc=15;
		double Td=2.0/3.0;
		double [] ref= {750/31.93,300/29.99};
		Controller ctrl=new Controller(ref,aTcVal,IPTGVal,sim,Ts,0.01/3,(0.04)/(48*4.5),true);
		
		
		
		// Set up a list of bacteria that will be present in the simulation
		final Vector<BSimCapsuleBacterium> moveBacteria = new Vector<BSimCapsuleBacterium>(); //This set is set up for the mover
		final Vector<BSimControlledBacterium> activeBacteria= new Vector<BSimControlledBacterium>();//The bacteria currently alive
		final Vector<BSimControlledBacterium> allBacteria= new Vector<BSimControlledBacterium>();//All bacteria ever existed in the simulation
		
		
		//Parameters for the chemical fields
		double kaTC=4.00e-2;
		double kIPTG=4.00e-2; // IPTG intracellular diffusion coefficient  (needed for the external chemical field dynamics)
		
		
		//Chemical Fields
		// Initialization of our aTC and IPTG chemical fields (we try to obtain a realistic representation of these files )
		final BSimChemicalField faTC = new ControlledFIeld(sim, new int[] {1,10,1}, 1, 0,activeBacteria,kaTC,4) ;//aTc Field
		final BSimChemicalField fIPTG = new ControlledFIeld(sim, new int[] {1,10,1}, 1, 0,activeBacteria,kIPTG,5);//IPTG Field
		
		//TO COMPARE THE RESULTS WITH THE MATLAB CASE THE BOX SHOUD BE 1 1 1 
		
		
		//Population Parameters
		int populationLimit=100; //the maximum number of cells currently alive 
		int populationInitialSize=1; //The initial population number
		Random rnd=new Random(); //Just to make the population initial position partially random
		
		
		
		//Population generation
		while(activeBacteria.size() < populationInitialSize) {		
			double bL = 1 + 0.1 * (rnd.nextDouble() - 0.5); //The initial length of a Bacterium
			double angle = 0 * Math.PI; //The starting angle (Vertical)
	   
			
            //Bacterium creation
			BSimControlledBacterium b;
			Vector3d pos = new Vector3d(0,sim.getBound().y-bL, sim.getBound().z / 2.0);
            Vector3d p1 = new Vector3d(pos.x - 0.5 * bL * Math.sin(angle), pos.y - 0.5 * bL * Math.cos(angle), pos.z);
            Vector3d p2 = new Vector3d(0.5 * bL * Math.sin(angle) + pos.x, 0.5 * bL * Math.cos(angle) + pos.y, pos.z);
        	b= new BSimControlledBacterium(sim, 
					p1,p2,faTC,fIPTG,activeBacteria,populationLimit,0); //the last argument is to set if the starting point is neart the equilibrium of high LacI(1) or low (0)
        	b.initialise(bL, p1, p2);
			//Add the bacterium to all lists
			activeBacteria.add(b);
			moveBacteria.add(b);
			allBacteria.add(b);
			
		}

		/*********************************************************
		 * Step 2: Implement tick() on a BSimTicker and add the ticker to the simulation	  
		 */
		

		sim.setTicker(new MyTicker(activeBacteria,faTC,fIPTG,sim,moveBacteria,allBacteria,populationLimit,ctrl,Ts,Tc,Td));
		
		
		/*********************************************************
		 * Step 3: Adding the drawer to see the results
		 */
		
		BSimDrawer dr=new ChamberDrawer(sim,1300 ,600 ,activeBacteria);//I set up the drawer for the simulation
		//BSimDrawer dr=new My3DDrawer(sim,1300 ,600 ,activeBacteria,faTC,fIPTG,ref );//I set up the drawer for the simulation
		sim.setDrawer(dr);
		
		/*********************************************************
		 * Step 3: Adding the exporters to see the results
		 */
		
		
		// Create a new directory for the simulation results
		String resultsDir = BSimUtils.generateDirectoryPath("./results/");			

		//This is to export the scene in a movie
		BSimMovExporter movExporter = new BSimMovExporter(sim, dr, resultsDir + "BSim.mov");
		movExporter.setDt(60*1);
		movExporter.setSpeed(60*40);//60*100
		//sim.addExporter(movExporter);	
		
		BSimPngExporter imgExp = new BSimPngExporter(sim, dr, resultsDir+"/images/");
		imgExp.setDt(60*5);
		sim.addExporter(imgExp);
	
		//These exporters are allowed to collect data (time,states and population number)
		BSimLogger Tlogger= new TimeLogger(sim,resultsDir + "TimeValues.csv");
		Tlogger.setDt(60*5); 
		sim.addExporter(Tlogger);
		BSimLogger bacteriaLogger= new BacteriaLogger(sim,resultsDir + "BacteriaValues.csv",allBacteria);
		bacteriaLogger.setDt(60*5);
		sim.addExporter(bacteriaLogger);
		BSimLogger poplogger= new PopulationLogger(sim,resultsDir + "PopulationValues.csv",activeBacteria);
		poplogger.setDt(60*5);
		sim.addExporter(poplogger);
		BSimLogger concl=new ConcLogger(sim,resultsDir + "FieldValues.csv",fIPTG);
		concl.setDt(60*10);
		sim.addExporter(concl);
		BSimLogger contl=new ControlLogger(sim,resultsDir + "ControlInput.csv",ctrl);
		contl.setDt(60*5); 
		sim.addExporter(contl);
		
		/*********************************************************
		 * Step 4: Starting the simulation
		 */
		
		sim.export();
	}
}

