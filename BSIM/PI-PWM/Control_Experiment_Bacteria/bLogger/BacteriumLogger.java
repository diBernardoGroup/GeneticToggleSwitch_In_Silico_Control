package bLogger;

import bBacterium.BSimControlledBacterium;
import bsim.BSim;
import bsim.export.BSimLogger;

public class BacteriumLogger extends BSimLogger {

	
	private BSimControlledBacterium b;
	
	
	public BacteriumLogger(BSim sim, String filename,BSimControlledBacterium b) {
		super(sim,filename);
		this.b=b;
	}
	
	
	@Override
	public void during() {
		
		String buffer = new String();
		if(b!=null) {
			buffer += b.y[0]+","+b.y[1]+","+b.y[2]+","+b.y[3]+",";
			if(buffer!=null) {
				write(buffer);
			}
		}
		
	}

}
