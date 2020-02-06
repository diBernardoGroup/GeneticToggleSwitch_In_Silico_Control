package bBacterium;

import bsim.BSim;
import bsim.ode.BSimOdeSystem;
import java.lang.Math;
import java.util.Random;

public class BacteriumInternalDynDiffusion implements BSimOdeSystem {

	// Number of equations in the system
	protected int numEq;
	
	// Variable for the initial conditions
	private int LacH;
	
	
	//Random number generator for the Weiner process
	private Random gaus;
	
	//RNumber of raction involved
	private int nreact;
	
	//time step
	private double dt;
	
	
	
	public BacteriumInternalDynDiffusion(int lacH,BSim sim) {
		//Set the state space dimention
		numEq = 6;

		//To get the right initial conditions
		this.LacH=lacH;
		
		//Initialization of the gaussian noise
		gaus=new Random();
		
		//Initialize the number of reactions
		nreact=8;
		dt=sim.getDt()/60;
	}
	
	
	@Override
	public double[] derivativeSystem(double t, double[] x) {
		
		double[] dx = new double[numEq];
		double[] w= new double[nreact];
		
		for (int i=0;i<nreact;i++) {
			w[i]=Math.sqrt(dt)*gaus.nextGaussian();
			//System.out.println("W ="+i+" ="+w[i]);
		}
		

		//Model Parameters
		double klm0=0.032;
		double klm=8.3;
		double thetaAtc=11.65;
		double etaAtc=2.00;
		double thetaTet=29.99;
		double etaTet=2;
		double glm=1.386e-1;
		double ktm0=0.119;
		double ktm=2.06;   
		double thetaIptg=0.0906;
		double etaIptg=2.00;
		double thetaLac=31.93;
		double etaLac=2.00;
		double gtm=1.386e-1;
		double klp=0.9726;
		double glp=1.65e-2;
		double ktp=1.1697;
		double gtp=1.65e-2;
		
		

		//Diffusion of the system
		
	    dx[0]=Math.sqrt(klm0+klm*HillFunc(x[3]*HillFunc(x[4],thetaAtc,etaAtc),thetaTet,etaTet))*w[6]-Math.sqrt(glm*x[0])*w[0];
	    	    
	    dx[1]=Math.sqrt(ktm0+ktm*HillFunc(x[2]*HillFunc(x[5],thetaIptg,etaIptg),thetaLac,etaLac))*w[7]-Math.sqrt(gtm*x[1])*w[1];

	    dx[2]=Math.sqrt(klp*x[0])*w[4]-Math.sqrt(glp*x[2])*w[2];
	    
	    dx[3]=Math.sqrt(ktp*x[1])*w[5]-Math.sqrt(gtp*x[3])*w[3];
	    
	    dx[4]=0;
	    
	    dx[5]=0;
	    
	    
		return dx;
		
		
	}

	//Utility function to get the derivative of the system
	private double HillFunc(double x, double th, double eta) {
		double hill=1/(1+Math.pow((x/th),eta));
		return hill;
	}


	//Initial conditions of the state
	@Override
	public double[] getICs() {
		double[] x0=new double[numEq];
		
		if (LacH==1) {
			x0[0]=11.2;
			x0[1]=0.89;
			x0[2]=660.57;
			x0[3]=63.32;
			x0[4]=0;
			x0[5]=0;
		}
		else {
			x0[0]=11.2;
			x0[1]=0.89;
			x0[2]=660.57;
			x0[3]=63.32;
			x0[4]=0;
			x0[5]=0;
		}
		
		
		return x0;
	}

	@Override
	public int getNumEq() {
		
		return numEq;
	}

	
	
	
}
