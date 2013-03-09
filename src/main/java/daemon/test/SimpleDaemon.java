package daemon.test;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;

public class SimpleDaemon implements Runnable {

	private static SimpleDaemon instance = new SimpleDaemon();
	private PrintStream ps;
	private Boolean started = false;
	private Thread thread;
	
	public synchronized boolean isStarted() {
		return started;
	}
	
	public SimpleDaemon() {
		try {
			String tmpdir = System.getProperty("java.io.tmpdir");
			ps = new PrintStream(new FileOutputStream(new File(tmpdir + "/simpledaemon_out.txt")));
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}
	
	public static void main(String args[]) {
		System.out.println("entering main()");
		
		Runtime.getRuntime().addShutdownHook(new Thread() {
			public void run() {
				System.out.println("shutdown hook invoked");
				windowsStop();
			}
		});

		windowsStart();
		System.out.println("returning from main()");
	}
	
	public static void windowsService(String args[]) {
		String cmd = "start";
		if (args.length > 0) {
			cmd = args[0];
		}

		if ("start".equals(cmd)) {
			windowsStart();
		} else if ("stop".equals(cmd)) {
			windowsStop();
		}
	}
	
	public static void windowsStart() {
		instance.ps.println("windowsStart() invoked");
		instance.start();
		while (instance.thread.isAlive()) {
			// don't return until stopped
			try {
				instance.thread.join();
			} catch (InterruptedException ie) {
				instance.ps.println("in windowsStart() - catched InterruptedException");
			}
		}
		instance.ps.println("returning from windowsStart()");
	}

	public static void windowsStop() {
		instance.ps.println("windowsStop() invoked");
		instance.stop();
	}

	public void start() {
		instance.ps.println("in start() - starting thread...");
		instance.thread = new Thread(instance);
		synchronized(instance) {
			instance.started = true;
		}
		instance.thread.run();
	}
	
	public void stop() {
		instance.ps.println("in start() - interrupting thread...");
		if (instance.thread != null) {
			instance.thread.interrupt();
		}
		synchronized(instance) {
			instance.started = false;
		}
	}

	@Override
	public void run() {
		int i = 0;		
		while (isStarted()) {
			try {
				instance.ps.println("in run() - i = " + i);
				Thread.sleep(1000);
				i++;
			} catch (InterruptedException e) {
				instance.ps.println("in run() - interrupting thread");
				break;
			}
		}
	}
}
