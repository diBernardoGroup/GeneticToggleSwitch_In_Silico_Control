package bLogger;

import bsim.BSim;
import bsim.export.BSimLogger;

public class TimeLogger extends BSimLogger {
 
	private BSim sim;
	
	public TimeLogger(BSim sim, String filename) {
		super(sim, filename);
		this.sim=sim;
	}

	@Override
	public void during() {
		// TODO Auto-generated method stub

		String buffer = new String();
		
		write(buffer+(sim.getTime()/60));
		
	}

}
