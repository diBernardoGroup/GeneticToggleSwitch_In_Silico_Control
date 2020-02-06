package bBacterium;

import bsim.ode.BSimOdeSystem;
import java.lang.Math;

public class BacteriumInternalDynDrift implements BSimOdeSystem {

	// Number of equations in the system
	protected int numEq;
			
	// External level of inducer - can get this from the chemical field
	protected double aTCext;	// [uM]
	protected double IPTGext;	
	
	// Variable for the initial conditions
	private int LacH;
	
	
	public BacteriumInternalDynDrift(int lacH) {
		//set the state space dimention
		numEq = 6;
		
		
		//Initial external inducers values
		aTCext=0;
		IPTGext=0;
		
		//For the initial condition(which is the starting equilibrium)
		this.LacH=lacH;
	}
	
	
	@Override
	public double[] derivativeSystem(double t, double[] x) {
		
		double[] dx = new double[numEq];
		
		
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
		double kaTC;
		double kIPTG;
		if(aTCext>x[4]) {
			kaTC=0.1623;
		}
		else kaTC=0.02;
		if(IPTGext>x[5]) {
			kIPTG=0.0275;
		}
		else kIPTG=0.111;

		
		

		//System dynamics
		
	    dx[0]=klm0+klm*HillFunc(x[3]*HillFunc(x[4],thetaAtc,etaAtc),thetaTet,etaTet)-glm*x[0];
	    
	    dx[1]=ktm0+ktm*HillFunc(x[2]*HillFunc(x[5],thetaIptg,etaIptg),thetaLac,etaLac)-gtm*x[1];

	    dx[2]=klp*x[0]-glp*x[2];
	    
	    dx[3]=ktp*x[1]-gtp*x[3];
	    
	    dx[4]=kaTC*(aTCext-x[4]);
	    
	    dx[5]=kIPTG*(IPTGext-x[5]);
	    
		return dx;
		
		
	}

	private double HillFunc(double x, double th, double eta) {
		double hill=1/(1+Math.pow((x/th),eta));
		return hill;
	}


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

	
	
	public void setfaTc(double val){
		aTCext=val;
	}
	
	public void setfIPTG(double val){
		IPTGext=val;
	}
	
	
	
}
