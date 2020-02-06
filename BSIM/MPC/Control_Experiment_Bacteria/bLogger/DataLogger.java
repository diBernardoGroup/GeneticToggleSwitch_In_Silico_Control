package bLogger;

import java.util.Vector;

import bBacterium.*;
import bsim.BSim;
import bsim.export.BSimLogger;

public class DataLogger extends BSimLogger {
			
			
	private Vector<BSimControlledBacterium> bacteria;
	private int varn;
	
	
		public DataLogger(BSim sim, String filename, Vector<BSimControlledBacterium> bacteria,int var) {
			super(sim, filename);
			this.bacteria=bacteria;
			varn=var;
		}

	@Override
			public void before() {
				super.before();
			}
			
			@Override
			public void during() {
				
				String buffer = new String();
				
				//buffer+=sim.getFormattedTime()+" ";
				
				for (BSimControlledBacterium b : bacteria) {
					buffer += b.y[varn]+",";
				}
									
				write(buffer);
				
			}
			
}
