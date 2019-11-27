create database HKVTravel
go 

use HKVTravel
go


-- Bảng Hướng dẫn viên
CREATE TABLE [dbo].[HuongDanVien](
	[MaHDV] [varchar](6) NOT NULL PRIMARY KEY,
	[TenHDV] [nvarchar](max) NOT NULL,
	[GioiTinh] [int] NULL,
	[NgaySinh] [date] NULL,
	[DiaChi] [nvarchar](max) NULL,
	[CMND] [nvarchar](12) NULL,
	[Email] [nvarchar](max) NULL,
	[DienThoai] [nvarchar](12) NULL,
	[TrangThai] bit default 0, 
	Anh image
)
GO
-- Bảng Nhân viên
create table dbo.NhanVien
(
	MaNV varchar(6) primary key,
	TenNV nvarchar(max) not null,
	GioiTinh int,
	NgaySinh date,
	DiaChi nvarchar(max),
	NgayVaoLam date,
	CMND nvarchar(12),
	Email varchar(MAX),
	DienThoai varchar(12),
	ChucVu bit,
	Anh image
)
go
-- Bảng Khách hàng
create table dbo.KhachHang
(
	MaKH varchar(6) primary key,
	TenKH nvarchar(max) not null,
	GioiTinh int,
	NgaySinh date,
	DiaChi nvarchar(max),
	CMND nvarchar(12),
	Email nvarchar(MAX),
	DienThoai nvarchar(12)
)
go
-- Bảng User
create table UserPassword
(
	ID varchar(6) primary key,
	Password varchar(max),
)
go
-- Bảng Khách Hàng tham gia Tour
create table KhachHangThamGia
(
	MaKhachHangTG varchar(6) primary key,
	MaHD varchar(6),
	TenKHTG nvarchar(max) not null,
	GioiTinh int,
	NgaySinh date,
	CMND nvarchar(12),
	DiaChi nvarchar(max),
	DonGia money,
)
go
-- Bảng Tour
create table Tour
(
	MaTour varchar(6) primary key,
	TenTour nvarchar(MAX) not null,
	NoiDi nvarchar(30),
	NoiDen nvarchar(30),
	NgayKhoiHanh date,
	NgayKetThuc date,
	GioKhoiHanh time,
	PhuongTien nvarchar(30),
	HienThi bit,
	GiaVe money,
	MaHDV varchar(6),
	Anh varchar(max),
	SoLuongKhachHang smallint
)
go


-- Bảng Chi tiết Tour
create table ChiTietTour
(
	MaChiTietTour varchar(6) primary key,
	MoTa nvarchar(MAX) not null,
	LichTrinh nvarchar(MAX),
	GhiChu nvarchar(MAX),
	Anh varchar(max)
)
go
-- Bảng Hoa đơn
create table HoaDon
(
	MaHD varchar(6) primary key,
	MaKH varchar(6),
	MaNV varchar(6),
	MaTour varchar(6),
	NgayLapHoaDon date,
)
go
-- Nhan Vien vs UserPassword
alter table NhanVien
add constraint FK_UserPassword_NhanVien foreign key (MaNV) references UserPassword(ID)
go
-- Khach Hang vs UserPassword
alter table KhachHang
add constraint FK_UserPassword_KhachHang foreign key (MaKH) references UserPassword(ID)

-- Khach Hang Tham Gia vs Hoa Don
alter table KhachHangThamGia 
add constraint FK_KHTG_HD foreign key (MaHD) references HoaDon(MaHD)
go
-- Khach Hang - gioitinh
alter table KhachHang
add constraint DF_KH_GioiTinh default((-1)) for GioiTinh
go
-- Nhan Vien - gioitinh
alter table NhanVien
add constraint DF_NV_GioiTinh default (-1) for GioiTinh
go

alter table KhachHangThamGia
add constraint DF_KHTG_GioiTinh default (-1) for GioiTinh
go
-- Hoa Don vs Khach Hang
alter table HoaDon 
add constraint FK_HoaDon_KhachHang foreign key (MaKH) references KhachHang(MaKH)
go
-- Hoa Don vs Nhan Vien
alter table HoaDon 
add constraint FK_HoaDon_NhanVien foreign key (MaNV) references NhanVien(MaNV)
go
-- Hoa Don vs Tour
alter table HoaDon
add constraint FK_HoaDon_Tour foreign key (MaTour) references Tour(MaTour)
go

-- Tour vs Chi tiet Tour
alter table ChiTietTour
add constraint FK_ChiTietTour_Tour foreign key (MaChiTietTour) references Tour(MaTour)
go
-- Tour vs HDV
alter table Tour
add constraint FK_Tour_HDV foreign key (MaHDV) references HuongDanVien(MaHDV)
go
-- Hàm tự phát sinh Mã Khách hàng
create function dbo.PhatSinhMaKH()
returns varchar(6)
as
	begin
		declare @ID varchar(6)
		if(select COUNT(*) from dbo.KhachHang) = 0
			begin
				set @ID = 'KH0001'
			end
		else
			begin
				select @ID = MAX(RIGHT(MaKH, 4)) from dbo.KhachHang
				select @ID = case
					when @ID >= 1 and @ID < 9 then 'KH000' + convert(varchar, convert(int, @ID)+1)
					when @ID >=9 and @ID < 100 then 'KH00' + convert(varchar, convert(int, @ID)+1)
					when @ID >=100  and @ID < 999 then 'KH0' + convert(varchar, convert(int, @ID)+1)
					when @ID >= 1000 THEN 'KH0' + convert(varchar, convert(int, @ID) + 1)
				end
			end
		return @ID
	end
go
-- Hàm tự phát sinh Mã Khách hàng tham gia
create function dbo.PhatSinhMaKHTG()
returns varchar(6)
as
begin
	declare @ID varchar(6)
	if(select COUNT(*) from KhachHangThamGia) = 0
		set @ID = 'TG0001'
	else
		begin
			select @ID = MAX(RIGHT(MaKhachHangTG, 4)) from KhachHangThamGia
			select @ID = case
				when @ID > 0 and @ID < 9 then 'TG000' + convert(char, convert(int, @ID)+1)
				when @ID >=9 and @ID < 100 then 'TG00' + convert(char, convert(int, @ID)+1)
				when @ID >=100  and @ID < 999 then 'TG0' + convert(char, convert(int, @ID)+1)
				when @ID >= 1000 THEN 'TG' + convert(char, convert(int, @ID) + 1)
			end
		end
	return @ID
end
go
-- Hàm tự phát sinh Mã Nhân viên
create function dbo.PhatSinhMaNV()
returns varchar(6)
as
begin
	declare @ID varchar(6)
	if(select COUNT(*) from dbo.NhanVien) = 0
		set @ID = 'NV0001'
	else
		begin
			select @ID = MAX(RIGHT(MaNV, 4)) from dbo.NhanVien
			select @ID = case
				when @ID > 0 and @ID < 9 then 'NV000' + convert(char, convert(int, @ID)+1)
				when @ID >=9 and @ID < 100 then 'NV00' + convert(char, convert(int, @ID)+1)
				when @ID >=100  and @ID < 999 then 'NV0' + convert(char, convert(int, @ID)+1)
				when @ID >= 1000 then 'NV' + convert(char, convert(int, @ID)+1)
			end
		end
	return @ID
end
go
create function [dbo].[PhatSinhMaHDV]()
returns varchar(6)
as
begin
	declare @ID varchar(6)
	if(select COUNT(*) from [dbo].[HuongDanVien]) = 0
		set @ID = 'HDV001'
	else
		begin
			select @ID = MAX(RIGHT(MaHDV, 3)) from [dbo].[HuongDanVien]
			select @ID = case
				when @ID > 0 and @ID < 9 then 'HDV00' + convert(char, convert(int, @ID)+1)
				when @ID >= 9  and @ID < 100 then 'HDV0' + convert(char, convert(int, @ID)+1)
				when @ID >= 100 then 'HDV' + convert(char, convert(int, @ID)+1)
			end
		end
	return @ID
end
go
-- Hàm tự phát sinh Mã Tour
create function dbo.PhatSinhMaTour()
returns varchar(6)
as
begin
	declare @ID varchar(6)
	if(select COUNT(*) from Tour) = 0
		set @ID = 'TT0001'
	else
		begin
			select @ID = MAX(RIGHT(MaTour, 4)) from Tour
			select @ID = case
				when @ID > 0 and @ID <+ 9 then 'TT000' + convert(char, convert(int, @ID)+1)
				when @ID >=9 and @ID < 100 then 'TT00' + convert(char, convert(int, @ID)+1)
				when @ID >=100  and @ID < 999 then 'TT0' + convert(char, convert(int, @ID)+1)
				when @ID >= 1000 then 'TT' + convert(char, convert(int, @ID)+1)
			end
		end
	return @ID
end
go
-- Hàm tự phát sinh Mã Hoa đơn
create function dbo.PhatSinhMaHD()
returns varchar(6)
as
begin
	declare @ID varchar(6)
	if(select COUNT(*) from HoaDon) = 0
		set @ID = 'HD0001'
	else
		begin
			select @ID = MAX(RIGHT(MaHD, 4)) from HoaDon
			select @ID = case
				when @ID > 0 and @ID < 9 then 'HD000' + convert(char, convert(int, @ID)+1)
				when @ID >=9 and @ID < 100 then 'HD00' + convert(char, convert(int, @ID)+1)
				when @ID >=100  and @ID < 999 then 'HD0' + convert(char, convert(int, @ID)+1)
				when @ID = 1000 THEN 'HD' + convert(char, convert(int, @ID) + 1)
			end
		end
	return @ID
end
go

-- Xuất dữ liệu các bảng
create procedure dbo.DocBang(@TenBang varchar(30))
as
	declare @temp varchar(100)
	set @temp = 'SELECT * FROM '+ @TenBang
	exec (@temp)
go


-- Thêm, xoá, sửa thông tin Khách Hàng
--exec dbo.CRUDKhachHang 1, '', 'Phan Sang Vô', 0, cast(1999-10-10 as date), ,N'Bạc Liêu','votech99@gmail.com', '0909090909', '123456'
create procedure dbo.CRUDKhachHang(@flag int,@MaKH varchar(10),@TenKH nvarchar(max), @GioiTinh int, @NgaySinh varchar(10), @DiaChi nvarchar(max), @CMND varchar(12), @Email varchar(max), @DienThoai varchar(12), @Password varchar(max))
as
	if(@flag = 1)
		begin
			declare @Ma varchar(6)
			set @Ma = dbo.PhatSinhMaKH()
			insert into UserPassword values (@Ma, @Password)
			insert into KhachHang values(@Ma, @TenKH, @GioiTinh, @NgaySinh, @DiaChi, @CMND, @Email, @DienThoai)
			
		end
	else if(@flag = 2)
		begin
			update KhachHang set TenKH = @TenKH, GioiTinh = @GioiTinh, NgaySinh = @NgaySinh, DiaChi = @DiaChi, CMND = @CMND, Email = @Email, DienThoai = @DienThoai 
			where MAKH = @MaKH
		end
	else if(@flag = 3)
		begin
			delete from KhachHang where MaKH = @MaKH
			delete from UserPassword where ID = @MaKH			
		end
go

-- Thêm, xoá, sửa thông tin Nhân viên
create procedure dbo.CRUDNhanVien(@flag int,@MaNV varchar(10),@TenNV nvarchar(max), @GioiTinh int, @NgaySinh varchar(10), @NgayVaoLam varchar(10), @CMND varchar(12), @DiaChi nvarchar(max), @Email varchar(max), @DienThoai varchar(12), @ChuVu bit, @Anh varbinary(max), @Password varchar(max))
as
	if(@flag = 1)
		begin
			declare @Ma varchar(6)
			set @Ma = dbo.PhatSinhMaNV()
			insert into UserPassword values (@Ma, @Password)
			insert into NhanVien values(@Ma, @TenNV, @GioiTinh, @NgaySinh, @DiaChi, @NgayVaoLam, @CMND, @Email, @DienThoai, @ChuVu, @Anh)
			
		end
	else if(@flag = 2)
		begin
			update NhanVien set TenNV = @TenNV, GioiTinh = @GioiTinh, NgaySinh = @NgaySinh, DiaChi = @DiaChi, NgayVaoLam = @NgayVaoLam, CMND = @CMND, Email = @Email, DienThoai = @DienThoai, ChucVu = @ChuVu, Anh = @Anh 
			where MaNV = @MaNV
		end
	else if(@flag = 3)
		begin
			delete from NhanVien where MaNV = @MaNV
			delete from UserPassword where ID = @MaNV
		end
go

-- Đổi ảnh đại diện Nhân viên
create procedure dbo.DoiAnhDaiDienNV(@ID varchar(10), @Anh varbinary(max))
as
	begin
		update dbo.NhanVien set Anh = @Anh
		where MaNV = @ID
	end	
go

create proc dbo.CRUDHuongDanVien(@flag int, @MaHDV varchar(6), @TenHDV nvarchar(max), @GioiTinh int, @NgaySinh varchar(10), @DiaChi nvarchar(max), @CMND nvarchar(12), @Email nvarchar(max), @DienThoai nvarchar(12), @TrangThai bit, @Anh varbinary(max))
as
	if(@flag=1)
		begin
			declare @Ma varchar(6)
			set @Ma = dbo.PhatSinhMaHDV()
			INSERT INTO [dbo].[HuongDanVien] VALUES (@Ma, @TenHDV, @GioiTinh, @NgaySinh, @DiaChi, @CMND, @Email, @DienThoai, @TrangThai, @Anh)
		end
	else if(@flag=2)
		begin
			update HuongDanVien set TenHDV = @TenHDV, GioiTinh = @GioiTinh, NgaySinh = @NgaySinh, DiaChi = @DiaChi, CMND = @CMND, Email = @Email, DienThoai = @DienThoai, TrangThai = @TrangThai, Anh = @Anh
			where MaHDV = @MaHDV
		end
	else if(@flag=3)
		begin
			delete
			from HuongDanVien
			where MaHDV = @MaHDV
		end
go

-- Đổi ảnh đại diện HDV
create procedure dbo.DoiAnhDaiDienHDV(@ID varchar(10), @Anh varbinary(max))
as
	begin
		update dbo.HuongDanVien set Anh = @Anh
		where MaHDV = @ID
	end	
go

-- Thêm, xoá, sửa thông tin Tour và Chi Tiết Tour
create procedure dbo.CRUDTour(@flag int, @MaTour varchar(10), @TenTour nvarchar(max), @NoiDi nvarchar(30), @NoiDen nvarchar(30), @NgayKhoiHanh varchar(10), @NgayKetThuc varchar(10), @GioKhoiHanh varchar(10), @PhuongTien nvarchar(30), @HienThi bit, @GiaVe money, @MaHDV varchar(6), @Anh varbinary(max), @SoLuong int,@MoTa nvarchar(max), @LichTrinh nvarchar(max), @GhiChu nvarchar(max), @DsAnh varchar(max))
as 
	if(@flag = 1)
		begin
			declare @Ma varchar(20)
			set @Ma = dbo.PhatSinhMaTour()
			insert into Tour values( @Ma, @TenTour, @NoiDi, @NoiDen, @NgayKhoiHanh, @NgayKetThuc, @GioKhoiHanh, @PhuongTien, @HienThi, @GiaVe, @MaHDV, @Anh, @SoLuong)
			insert into ChiTietTour values( @Ma, @MoTa, @LichTrinh, @GhiChu, @DsAnh)
		end
	else if(@flag = 2)
		begin
			update Tour set TenTour = @TenTour, NoiDi = @NoiDi, NoiDen = @NoiDen, NgayKhoiHanh = @NgayKhoiHanh, NgayKetThuc = @NgayKetThuc, GioKhoiHanh = @GioKhoiHanh, PhuongTien = @PhuongTien, HienThi = @HienThi, GiaVe = @GiaVe, MaHDV = @MaHDV, Anh = @Anh
			where MaTour = @MaTour

			update ChiTietTour set MoTa = @MoTa,  LichTrinh = @LichTrinh, GhiChu = @GhiChu, Anh = @DsAnh
			where MaChiTietTour = @MaTour
		end
	else if(@flag = 3)
		begin
			delete from Tour where MaTour = @MaTour
			delete from ChiTietTour where MaChiTietTour = @MaTour
		end
go

-- Danh sách Khách hàng theo Tour
create procedure dbo.DanhSachKhachHangTheoTour(@MaTour char(10))
as

	begin
		select t.MaTour, q.TenKHTG, q.GioiTinh, q.NgaySinh, q.DiaChi
		from Tour t
			join HoaDon h on h.MaTour = t.MaTour
			join KhachHangThamGia q on h.MaHD = q.MaHD
		where t.MaTour = @MaTour and h.MaHD = q.MaHD
	end
go

-- Danh sách Khách hàng theo Hoá Đơn
create procedure dbo.KhachHangDatHoaDon(@MaHoaDon varchar(10))
as
	begin
		select kh.MaKh, kh.TenKH, kh.GioiTinh, kh.NgaySinh, kh.DiaChi, kh.Email, kh.DienThoai
		from KhachHang kh 
			join HoaDon hd on hd.MaKh = kh.MaKh
		where hd.MaHD = @MaHoaDon
	end
go

create procedure dbo.DanhSachKhachHangTheoHoaDon(@MaHoaDon varchar(10))
as 
	begin
		select hd.MaHD, t.MaTour, tg.TenKHTG, tg.GioiTinh, tg.NgaySinh, tg.DiaChi
		from HoaDon hd
			join Tour t on hd.MaTour = t.MaTour
			join KhachHangThamGia tg on tg.MaHD = tg.MaHD
		where hd.MaHD = @MaHoaDon
	end
go

---- Phân quyền
create function phanQuyen(@TaiKhoan varchar(20))
returns int
as
	begin
		declare @Ma varchar(6)
		select @Ma = (
						select MaKH
						from dbo.KhachHang
						where Email = @TaiKhoan or DienThoai = @TaiKhoan
						)
		if(@Ma is not null)
			return 1
		return 0
	end
go

---- Truy xuất mật khẩu
create function timMatKhau(@TaiKhoan varchar(max))
returns varchar(20)
as
	begin
		declare @MatKhau varchar(20)
		declare @Ma varchar(max)

		select @MatKhau = up.Password, @Ma = nv.MaNV
		from NhanVien nv
			join UserPassword up on nv.MaNV = up.ID
		where nv.DienThoai = @TaiKhoan or nv.Email = @TaiKhoan

		if(@MatKhau is null)
			begin
				select @MatKhau = up.Password, @Ma = kh.MaKH
				from KhachHang kh
					join UserPassword up on kh.MaKH = up.ID
				where kh.DienThoai = @TaiKhoan or kh.Email = @TaiKhoan
			end
		return @MatKhau
	end
go

-- Đổi mật khẩu
create procedure dbo.DoiMatKhau (@Id varchar(6), @Password varchar(max))
as
	begin
		update UserPassword set Password = @Password
		where ID = @Id
	end
go

-- Cập nhật mật khẩu
create function dbo.CapNhatTaiKhoan(@Id varchar(6))
returns varchar(20)
as
	begin
		declare @Password varchar(20)
		select @Password = Password 
		from UserPassword
		where ID = @Id
		return @Password
	end
go
------ Tìm Khách hàng
--create procedure dbo.TimKhachHang(@TaiKhoan varchar(max), @MatKhau varchar(max))
--as
--	begin
--		select kh.MaKh, kh.TenKH, kh.GioiTinh, kh.NgaySinh, kh.DiaChi, kh.Email, kh.DienThoai from KhachHang kh 
--			join UserPassword up on kh.MaKh = up.ID
--		where (kh.Email = @TaiKhoan or kh.DienThoai = @TaiKhoan) and up.Password = @MatKhau
--	end
--go
------ Tìm Nhân viên
--create procedure dbo.TimNhanVien(@TaiKhoan varchar(max), @MatKhau varchar(max))
--as
--	begin
--		select nv.MaNV, nv.TenNV, nv.GioiTinh, nv.NgaySinh, nv.NgayVaoLam, nv.DiaChi, nv.CMND, nv.Email, nv.DienThoai, nv.ChucVu
--		from NhanVien nv 
--			join UserPassword up on nv.MaNV = up.ID
--		where (nv.Email = @TaiKhoan or nv.DienThoai = @TaiKhoan) and up.Password = @MatKhau
--	end
--go

-- Tìm nhân viên bằng MaNV
create procedure dbo.TimNhanVienByMaNV(@MaNV varchar(6))
as
	begin
		select * from NhanVien
		where MaNV = @MaNV
	end
go
-- Tìm chi Tiết tour
create procedure dbo.TimChiTietTour(@MaTour varchar(6))
as
	begin
		select ct.* from Tour t join ChiTietTour ct on t.MaTour = ct.MaChiTietTour
		where t.MaTour = @MaTour
	end
go

create procedure [dbo].[DangNhap] (@Username nvarchar(max), @Password varchar(max))
as
	begin
		declare @ID varchar(max)
		select @ID = kh.MaKH from KhachHang kh
		join UserPassword up on kh.MaKH = up.ID
		where (kh.Email = @Username or kh.DiaChi = @Username) and up.Password = @Password

		if(@ID is null)
			begin
				select @ID = nv.MaNV from NhanVien nv
				join UserPassword up on nv.MaNV = up.ID
				where (nv.Email = @Username or nv.DienThoai = @Username) and up.Password = @Password
			end
		select * from UserPassword where ID = @ID
	end

GO

create procedure dbo.DangNhapNV(@ID varchar(6))
as
	begin
		select * from dbo.NhanVien
		where MaNV = @ID 
	end
go


create procedure dbo.DangNhapKH(@ID varchar(6))
as
	begin
		select * from dbo.KhachHang
		where MaKH = @ID
	end
go
-- Thống kê

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LAP HOA DON 
create procedure [dbo].[CRUDHoaDonKhachHang]( @MaHD varchar(6), @MaKH varchar(6), @MaNV varchar(6), @MaTour varchar(20), @NgayLapHoaDon varchar(10))
as
		begin
			declare  @MaHDTemp varchar(6)
			set @MaHDTemp = dbo.PhatSinhMaHD()
			insert into HoaDon values(@MaHDTemp, @MaKH, @MaNV, @MaTour, @NgayLapHoaDon)
		
		end

GO

-- THEM DU LIEU KHACH HANG THAM GIA

create procedure [dbo].[CRUDKhachHangLienQuan]( @MaKhachHangTG varchar(6), @MaHD varchar(10),@Ten nvarchar(max), @GioiTinh bit, @NgaySinh varchar(10), @CMND varchar(9), @DiaChi nvarchar(max), @DonGia money)
as
		begin
			declare @Ma varchar(20)
			set @Ma = dbo.PhatSinhMaKHTG()
			insert into KhachHangThamGia values(@Ma, @MaHD,@Ten, @GioiTinh, @NgaySinh, @CMND, @DiaChi, @DonGia)
		end


GO

create procedure [dbo].[TimHoaDon]
as
		begin
		select MAX(MaHD) from HoaDon
		end

GO

-- lay thong tin khach hang
create function KhachHang_TimMa (@User nvarchar(max),@sdt nvarchar(12))
returns table
as 
return (select * 
		from KhachHang
		where  @User=Email or @sdt=DiaChi)
go
-- DANH SÁCH TOUR ĐÃ ĐẶT
--create procedure DanhSachTourDaDat(@maKH varchar(6))
--as
--	begin 
--		select hd.MaHD, t.MaTour, t.TenTour, t.NoiDi, t.NoiDen, t.NgayKhoiHanh, t.NgayKetThuc, t.GioKhoiHanh, t.PhuongTien, t.GiaVe,t.Anh, kh.*, nv.MaNV, nv.TenNV, hd.NgayLapHoaDon,
--		TongGia=sum(khtg.DonGia),SoLuongKh = count(khtg.MaKhachHangTG)	
--		from HoaDon hd
--				join KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
--				join KhachHang kh on hd.MaKH = kh.MaKH
--				join Tour t on t.MaTour=hd.MaTour
--				join dbo.NhanVien nv on hd.MaNV = nv.MaNV
--				where kh.MaKH = @maKH
--		group by hd.MaHD,t.MaTour,t.TenTour,t.NoiDi, t.NoiDen, t.NgayKhoiHanh, t.NgayKetThuc, t.GioKhoiHanh, t.PhuongTien, t.GiaVe,t.Anh,kh.MaKH,kh.TenKH,kh.CMND,kh.DiaChi,kh.DienThoai,kh.Email,kh.GioiTinh,kh.NgaySinh, nv.MaNV, nv.TenNV, hd.NgayLapHoaDon
--		order by hd.NgayLapHoaDon desc
--	end
--go 
-- DANHSACH KHÁCH HÀNG THAM GIA TOUR

create procedure DanhSachKhachHangThamGiaTour(@maHD varchar(6))
as
	begin 
		select k.TenKHTG,k.GioiTinh,k.CMND,k.NgaySinh,k.DiaChi,k.DonGia
		from HoaDon h join KhachHangThamGia k on h.MaHD=k.MaHD
		where h.MaHD like @maHD
	end
go

-- DANH SÁCH HÓA ĐƠN
create procedure dbo.DanhSachHoaDon
as
	begin
		select hd.MaHD, t.TenTour, kh.TenKH, hd.NgayLapHoaDon, SUM(khtg.DonGia) from HoaDon hd
			join KhachHang kh on hd.MaKH = kh.MaKH
			join Tour t on hd.MaTour = t.MaTour
			join KhachHangThamGia khtg on khtg.MaHD = hd.MaHD
		group by hd.MaHD, t.TenTour, kh.TenKH, hd.NgayLapHoaDon
	end
go

--TÌM TOUR HIỆN DANH SÁCH
create procedure TimDanhSachTour(@TenTour nvarchar(Max))
as
	begin 
		select *
		from Tour
		where TenTour like  '%'+@TenTour+'%'
	end
go
-- xoa hoa don
create procedure XoaHoaDon(@ma nvarchar(6))
as
	begin
		delete from KhachHangThamGia where MaHD=@ma
		delete from HoaDon where MaHD=@ma
	end
go
-- danh sách tour  hiện tại 
create procedure DanhSachTourHienTai
as 
	begin
		select *
		from Tour
		where DATEDIFF(DAY,GETDATE(),NgayKhoiHanh)>0
	end
go 
 -- LỌC TÌM KIẾM
 create procedure BoLocTimKiem(@NoiDi nvarchar(30),@NoiDen nvarchar(30),@NgayKhoiHanh varchar(10),@NgayKetThuc varchar(10),@PhuongTien nvarchar(30),@GiaDau money ,@giaCuoi money)
 as
	begin
		select *
		from Tour
		 where @GiaDau <= GiaVe and GiaVe < @giaCuoi and NgayKetThuc like '%'+@NgayKetThuc+'%' and NgayKhoiHanh like '%'+@NgayKhoiHanh+'%' and  NoiDen like '%'+@NoiDen+'%' and NoiDi like'%'+ @NoiDi+'%' and PhuongTien like '%'+@PhuongTien+'%'
	end
go
--thong ke
create procedure dbo.Ngay(@thang int, @nam int)
as
	
	begin
		select distinct day(NgayLapHoaDon) from [dbo].[HoaDon] where year(NgayLapHoaDon) = @nam and month(NgayLapHoaDon) = @thang order by day(NgayLapHoaDon)
	end
go

create procedure dbo.Thang(@nam int)
as
	begin
		select distinct month(NgayLapHoaDon) from [dbo].[HoaDon] where year(NgayLapHoaDon) = @nam order by month(NgayLapHoaDon)
	end
go

create procedure dbo.Quy(@nam int)
as
	begin
		select distinct datepart(q,NgayLapHoaDon) from [dbo].[HoaDon] where year(NgayLapHoaDon) = @nam order by datepart(q,NgayLapHoaDon)
	end
go

create procedure dbo.Nam
as
	begin
		select distinct year(NgayLapHoaDon) from [dbo].[HoaDon] order by year(NgayLapHoaDon)
	end
go


create proc dbo.ThongKeDoanhThuTheoThang @thang int, @nam int
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaHD in (	select MaHD
						from [dbo].[HoaDon]
						where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang)
	end
go
create proc dbo.ThongKeDoanhThuTheoNgay @ngay int, @thang int, @nam int
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaHD in (	select MaHD
						from [dbo].[HoaDon]
						where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang and day(NgayLapHoaDon) = @ngay)
	end
go
create proc dbo.ThongKeDoanhThuTheoQuy @quy int, @nam int
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaHD in (	select MaHD
						from [dbo].[HoaDon]
						where YEAR(NgayLapHoaDon) = @nam and datepart(qq, NgayLapHoaDon) = @quy)
	end
go

create proc dbo.ThongKeDoanhThuTheoNam @nam int
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaHD in (	select MaHD
						from [dbo].[HoaDon]
						where YEAR(NgayLapHoaDon) = @nam)
	end
go
create proc dbo.ThongKeDoanhThu
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[KhachHangThamGia]
	end
go
create proc dbo.ThongKeSoHoaDonTheoNam @nam int
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam
	end
go
create proc dbo.ThongKeSoHoaDonTheoThang @thang int, @nam int
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang
	end
go
create proc dbo.ThongKeSoHoaDonTheoNgay @ngay int, @thang int, @nam int
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang and day(NgayLapHoaDon) = @ngay
	end
go
create proc dbo.ThongKeSoHoaDonTheoQuy @quy int, @nam int
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and datepart(qq, NgayLapHoaDon) = @quy
	end
go
create proc dbo.ThongKeSoHoaDon
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
	end
go
--Thong ke theo khach hang
create proc dbo.ThongKeDoanhThuKHTheoThang @maKH nvarchar, @thang int, @nam int
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaHD in (	select MaHD
						from [dbo].[HoaDon]
						where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang)
		and h.MaKH = @maKH
	end
go
create proc dbo.ThongKeDoanhThuKHTheoNgay @maKH nvarchar, @ngay int, @thang int, @nam int
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaHD in (	select MaHD
						from [dbo].[HoaDon]
						where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang and day(NgayLapHoaDon) = @ngay)
		and h.MaKH = @maKH
	end
go
create proc dbo.ThongKeDoanhThuKHTheoQuy @maKH nvarchar, @quy int, @nam int
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaHD in (	select MaHD
						from [dbo].[HoaDon]
						where YEAR(NgayLapHoaDon) = @nam and datepart(qq, NgayLapHoaDon) = @quy)
		and h.MaKH = @maKH
	end
go

create proc dbo.ThongKeDoanhThuKHTheoNam @maKH nvarchar, @nam int
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaHD in (	select MaHD
						from [dbo].[HoaDon]
						where YEAR(NgayLapHoaDon) = @nam)
		and h.MaKH = @maKH
	end
go
create proc dbo.ThongKeDoanhThuKH @maKH nvarchar
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaKH = @maKH
	end
go
create proc dbo.ThongKeSoHoaDonKHTheoNam @maKH nvarchar, @nam int
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and MaKH = @maKH
	end
go
create proc dbo.ThongKeSoHoaDonKHTheoThang @maKH nvarchar, @thang int, @nam int
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang and MaKH = @maKH
	end
go
create proc dbo.ThongKeSoHoaDonKHTheoNgay @maKH nvarchar, @ngay int, @thang int, @nam int
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang and day(NgayLapHoaDon) = @ngay and MaKH = @maKH
	end
go
create proc dbo.ThongKeSoHoaDonTheoKHQuy @maKH nvarchar, @quy int, @nam int
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and datepart(qq, NgayLapHoaDon) = @quy and MaKH = @maKH
	end
go
create proc dbo.ThongKeSoHoaDonKH @maKH nvarchar
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where MaKH = @maKH
	end
go

--Thong ke theo nhan vien
create proc dbo.ThongKeDoanhThuNVTheoThang @maNV nvarchar, @thang int, @nam int
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaHD in (	select MaHD
						from [dbo].[HoaDon]
						where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang)
		and h.MaNV = @maNV
	end
go
create proc dbo.ThongKeDoanhThuNVTheoNgay @maNV nvarchar, @ngay int, @thang int, @nam int
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaHD in (	select MaHD
						from [dbo].[HoaDon]
						where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang and day(NgayLapHoaDon) = @ngay)
		and h.MaNV = @maNV
	end
go
create proc dbo.ThongKeDoanhThuNVTheoQuy @maNV nvarchar, @quy int, @nam int
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaHD in (	select MaHD
						from [dbo].[HoaDon]
						where YEAR(NgayLapHoaDon) = @nam and datepart(qq, NgayLapHoaDon) = @quy)
		and h.MaNV = @maNV
	end
go

create proc dbo.ThongKeDoanhThuNVTheoNam @maNV nvarchar, @nam int
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaHD in (	select MaHD
						from [dbo].[HoaDon]
						where YEAR(NgayLapHoaDon) = @nam)
		and h.MaNV = @maNV
	end
go
create proc dbo.ThongKeDoanhThuNV @maNV nvarchar
as
	begin
		select sum(DonGia) as DoanhThu
		from [dbo].[HoaDon] h join [dbo].[KhachHangThamGia] k on h.MaHD = k.MaHD
		where h.MaNV = @maNV
	end
go
create proc dbo.ThongKeSoHoaDonNVTheoNam @maNV nvarchar, @nam int
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and MaNV = @maNV
	end
go
create proc dbo.ThongKeSoHoaDonNVTheoThang @maNV nvarchar, @thang int, @nam int
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang and MaNV = @maNV
	end
go
create proc dbo.ThongKeSoHoaDonNVTheoNgay @maNV nvarchar, @ngay int, @thang int, @nam int
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang and day(NgayLapHoaDon) = @ngay and MaNV = @maNV
	end
go
create proc dbo.ThongKeSoHoaDonTheoNVQuy @maNV nvarchar, @quy int, @nam int
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and datepart(qq, NgayLapHoaDon) = @quy and MaNV = @maNV
	end
go
create proc dbo.ThongKeSoHoaDonNV @maNV nvarchar
as
	begin
		select count(*) as SoHoaDon
		from [dbo].[HoaDon]
		where MaNV = @maNV
	end
go
--thong ke hoa don
create procedure [dbo].[DanhSachHoaDonTheoNam] @nam int
as
	begin
		select hd.MaHD, t.*, kh.*, nv.MaNV, nv.TenNV, hd.NgayLapHoaDon, (
			select SUM(khtg.DonGia) from HoaDon hd
				join KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
			group by hd.MaHD
		) as TongGia, (
			select COUNT(*) from HoaDon hd
				join KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
				join KhachHang kh on hd.MaKH = kh.MaKH
			group by hd.MaHD
		) as SoLuongKhachHang
		from dbo.HoaDon hd 
			join dbo.Tour t on hd.MaTour = t.MaTour
			join dbo.KhachHang kh on hd.MaKH = kh.MaKH
			join dbo.NhanVien nv on hd.MaNV = nv.MaNV
			join dbo.KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
		where year(hd.NgayLapHoaDon) = @nam
	end

GO
create procedure [dbo].[DanhSachHoaDonTheoThang] @thang int, @nam int
as
	begin
		select hd.MaHD, t.*, kh.*, nv.MaNV, nv.TenNV, hd.NgayLapHoaDon, (
			select SUM(khtg.DonGia) from HoaDon hd
				join KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
			group by hd.MaHD
		) as TongGia, (
			select COUNT(*) from HoaDon hd
				join KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
				join KhachHang kh on hd.MaKH = kh.MaKH
			group by hd.MaHD
		) as SoLuongKhachHang
		from dbo.HoaDon hd 
			join dbo.Tour t on hd.MaTour = t.MaTour
			join dbo.KhachHang kh on hd.MaKH = kh.MaKH
			join dbo.NhanVien nv on hd.MaNV = nv.MaNV
			join dbo.KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
		where year(hd.NgayLapHoaDon) = @nam and month(hd.NgayLapHoaDon) = @thang
	end

GO
create procedure [dbo].[DanhSachHoaDonTheoQuy] @quy int, @nam int
as
	begin
		select hd.MaHD, t.*, kh.*, nv.MaNV, nv.TenNV, hd.NgayLapHoaDon, (
			select SUM(khtg.DonGia) from HoaDon hd
				join KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
			group by hd.MaHD
		) as TongGia, (
			select COUNT(*) from HoaDon hd
				join KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
				join KhachHang kh on hd.MaKH = kh.MaKH
			group by hd.MaHD
		) as SoLuongKhachHang
		from dbo.HoaDon hd 
			join dbo.Tour t on hd.MaTour = t.MaTour
			join dbo.KhachHang kh on hd.MaKH = kh.MaKH
			join dbo.NhanVien nv on hd.MaNV = nv.MaNV
			join dbo.KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
		where year(NgayLapHoaDon) = @nam and datepart(qq, hd.NgayLapHoaDon) = @quy
	end

GO
create procedure [dbo].[DanhSachHoaDonTheoNgay] @ngay int, @thang int, @nam int
as
	begin
		select hd.MaHD, t.*, kh.*, nv.MaNV, nv.TenNV, hd.NgayLapHoaDon, (
			select SUM(khtg.DonGia) from HoaDon hd
				join KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
			group by hd.MaHD
		) as TongGia, (
			select COUNT(*) from HoaDon hd
				join KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
				join KhachHang kh on hd.MaKH = kh.MaKH
			group by hd.MaHD
		) as SoLuongKhachHang
		from dbo.HoaDon hd 
			join dbo.Tour t on hd.MaTour = t.MaTour
			join dbo.KhachHang kh on hd.MaKH = kh.MaKH
			join dbo.NhanVien nv on hd.MaNV = nv.MaNV
			join dbo.KhachHangThamGia khtg on hd.MaHD = khtg.MaHD
		where year(hd.NgayLapHoaDon) = @nam and month(hd.NgayLapHoaDon) = @thang and day(hd.NgayLapHoaDon) = @ngay
	end

GO

create proc dbo.ThongKeSoLuongKHTheoNgay @ngay int, @thang int, @nam int
as
	begin
		select count(*) as SoLuongKH
		from [dbo].[KhachHangThamGia]
		where MaHD in (select MaHD
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang and day(NgayLapHoaDon) = @ngay)
	end
go

create proc dbo.ThongKeSoLuongKHTheoThang @thang int, @nam int
as
	begin
		select count(*) as SoLuongKH
		from [dbo].[KhachHangThamGia]
		where MaHD in (select MaHD
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and MONTH(NgayLapHoaDon) = @thang)
	end
go

create proc dbo.ThongKeSoLuongKHTheoQuy @quy int, @nam int
as
	begin
		select count(*) as SoLuongKH
		from [dbo].[KhachHangThamGia]
		where MaHD in (select MaHD
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam and datepart(qq, NgayLapHoaDon)= @quy)
	end
go

create proc dbo.ThongKeSoLuongKHTheoNam @nam int
as
	begin
		select count(*) as SoLuongKH
		from [dbo].[KhachHangThamGia]
		where MaHD in (select MaHD
		from [dbo].[HoaDon]
		where YEAR(NgayLapHoaDon) = @nam)
	end
go




--use master
--go

use master

--drop database HKVTravel
--go

