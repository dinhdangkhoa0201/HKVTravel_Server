package server;

import java.rmi.Naming;
import java.rmi.registry.LocateRegistry;

import services.ChiTietTourServices;
import services.HoaDonServices;
import services.HuongDanVienServices;
import services.KhachHangServices;
import services.KhachHangThamGiaServices;
import services.NhanVienServices;
import services.TourServices;
import services.UserPasswordServices;
import services.imp.ChiTietTourImp;
import services.imp.HoaDonImp;
import services.imp.HuongDanVienImp;
import services.imp.KhachHangImp;
import services.imp.KhachHangThamGiaImp;
import services.imp.NhanVienImp;
import services.imp.TourImp;
import services.imp.UserPasswordImp;

public class Server_Main {
	private static final String IP = "localhost";
	private static final String PORT = "1999";
	
	public static void main(String[] args) {
		try {
			SecurityManager securityManager = System.getSecurityManager();
			if(securityManager == null) {
				System.setProperty("java.security.plicy", "mypolicy/policy.policy");
				securityManager = new SecurityManager();
			}
			ChiTietTourServices chiTietTourServices = new ChiTietTourImp();
			HoaDonServices hoaDonServices = new HoaDonImp();
			HuongDanVienServices huongDanVienServices = new HuongDanVienImp();
			KhachHangServices khachHangServices = new KhachHangImp();
			KhachHangThamGiaServices khachHangThamGiaServices = new KhachHangThamGiaImp();
			NhanVienServices nhanVienServices = new NhanVienImp();
			TourServices tourServices = new TourImp();
			UserPasswordServices userPasswordServices = new UserPasswordImp();
			
			LocateRegistry.createRegistry(1999);
			
			Naming.rebind("rmi://"+IP+":"+PORT+"/chiTietTourServices", chiTietTourServices);
			Naming.rebind("rmi://"+IP+":"+PORT+"/hoaDonServices", hoaDonServices);
			Naming.rebind("rmi://"+IP+":"+PORT+"/huongDanVienServices", huongDanVienServices);
			Naming.rebind("rmi://"+IP+":"+PORT+"/khachHangServices", khachHangServices);
			Naming.rebind("rmi://"+IP+":"+PORT+"/khachHangThamGiaServices", khachHangThamGiaServices);
			Naming.rebind("rmi://"+IP+":"+PORT+"/nhanVienServices", nhanVienServices);
			Naming.rebind("rmi://"+IP+":"+PORT+"/tourServices", tourServices);
			Naming.rebind("rmi://"+IP+":"+PORT+"/userPasswordServices", userPasswordServices);
			System.out.println("Server is ready");
		} catch (Exception e) {
			System.out.println("Server đang chạy");
			System.exit(0);
		}
	}
}
