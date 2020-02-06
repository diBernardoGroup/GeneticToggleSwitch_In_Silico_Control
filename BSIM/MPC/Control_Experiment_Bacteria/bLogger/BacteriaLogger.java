package bLogger;

import java.util.Vector;

import bBacterium.BSimControlledBacterium;
import bsim.BSim;
import bsim.export.BSimLogger;

public class BacteriaLogger extends BSimLogger {
	
	private Vector<BSimControlledBacterium> bacteria;

	public BacteriaLogger(BSim sim, String filename,Vector<BSimControlledBacterium> bacteria) {
		super(sim, filename);
		this.bacteria=bacteria;
		// TODO Auto-generated constructor stub
	}

	@Override
	public void during() {
		// TODO Auto-generated method stub
		
		String buffer = new String();
		for (BSimControlledBacterium b : bacteria) {
			buffer += b.y[0]+","+b.y[1]+","+b.y[2]+","+b.y[3]+","+b.y[4]+","+b.y[5]+",";
		}
		
		write(buffer);
		
	}

}
