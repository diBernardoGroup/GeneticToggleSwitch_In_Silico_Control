package bSolver;



import bsim.ode.BSimOdeSystem;

public class BSimEulerMaruyama {

	// Drift and diffusion of the SDE 
	private BSimOdeSystem Drift;
	private BSimOdeSystem Diffusion;
	
	//Simulation Parameters
	private double dt;
	private int neq;
	

	public BSimEulerMaruyama (BSimOdeSystem Drift,BSimOdeSystem Diffusion,double dt) {
		this.Drift=Drift;
		this.Diffusion=Diffusion; //THe diffusion term has inside all the sochasticity (also the evaluation of noise) (it's just a trial it shold be done better)
		this.dt=dt;
		this.neq=Drift.getNumEq();
	}
	
	
	public double[] Euler_Maruyama(double [] state,double t) {
		
		double[] y_new =new double[neq];
		
		
		double[] det=Drift.derivativeSystem(t, state);
		double[] stoc=Diffusion.derivativeSystem(t, state);
		
		
		
		for (int i=0;i<neq;i++) {
			y_new[i]=state[i]+det[i]*dt+stoc[i];
			if (y_new[i]<0) {
				y_new[i]=0;
			}
		}
		
		
		return y_new;
		
	}
	
}
