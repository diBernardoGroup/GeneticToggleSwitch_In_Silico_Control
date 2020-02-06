package bLogger;


import bControl.Controller;
import bsim.BSim;
import bsim.BSimChemicalField;
import bsim.export.BSimLogger;

public class ControlLogger extends BSimLogger {

	
	Controller c;
	
	public ControlLogger(BSim sim, String filename,Controller c) {
		super(sim,filename);
		this.c=c;
	}
	
	
	@Override
	public void during() {
		
		String buffer = new String();
		buffer=c.D+","+c.curr_e+",";
		write(buffer);
		
	}

}
