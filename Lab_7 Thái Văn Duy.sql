IF NOT EXISTS(SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        PRINT 'Mã nhân viên không tồn tại'
        RETURN
    END

    IF EXISTS(SELECT * FROM Nhap WHERE sohdn = @sohdn)
    BEGIN
        UPDATE Nhap SET masp = @masp, manv = @manv, ngaynhap = @ngaynhap, soluongN = @soluongN, dongiaN = @dongiaN
        WHERE sohdn = @sohdn
    END
    ELSE 
    BEGIN
        INSERT INTO Nhap(sohdn, masp, manv, ngaynhap, soluongN, dongiaN)
        VALUES(@sohdn, @masp, @manv, @ngaynhap, @soluongN, @dongiaN)
    END


    IF EXISTS(SELECT * FROM Xuat WHERE sohdx = @sohdn)
    BEGIN
        UPDATE Xuat SET masp = @masp, manv = @manv, ngayxuat = @ngaynhap, soluongX = @soluongN
        WHERE sohdx = @sohdn
    END
    ELSE
    BEGIN
        DECLARE @sohdx varchar(20)
        SET @sohdx = 'X' + @sohdn
        INSERT INTO Xuat(sohdx, masp, manv, ngayxuat, soluongX)
        VALUES(@sohdx, @masp, @manv, @ngaynhap, @soluongN)
    END
END
go

--Cau 6--
go
CREATE PROCEDURE Cau_6(
    @sohdx INT,
    @masp INT,
    @manv INT,
    @ngayxuat DATE,
    @soluongX INT
)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        PRINT 'Không tồn tại mã sản phẩm.'
        RETURN
    END
    
    IF NOT EXISTS (SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        PRINT 'Không tồn tại mã nhân viên.'
        RETURN
    END
    
    IF @soluongX > (SELECT soluong FROM Sanpham WHERE masp = @masp)
    BEGIN
        PRINT 'Số lượng xuất vượt quá số lượng tồn kho.'
        RETURN
    END
    
    IF EXISTS (SELECT * FROM Xuat WHERE sohdx = @sohdx)
    BEGIN
        UPDATE Xuat 
        SET masp = @masp, manv = @manv, ngayxuat = @ngayxuat, soluongX = @soluongX 
        WHERE sohdx = @sohdx
        PRINT 'Cập nhật dữ liệu thành công.'
    END
    ELSE
    BEGIN
        INSERT INTO Xuat(sohdx, masp, manv, ngayxuat, soluongX)
        VALUES (@sohdx, @masp, @manv, @ngayxuat, @soluongX)
        PRINT 'Thêm dữ liệu thành công.'
    END
END
go

--Cau 7--
go
CREATE PROCEDURE Cau_7 
    @manv INT
AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        PRINT 'Không tìm thấy nhân viên với mã ' + CAST(@manv AS NVARCHAR)
        RETURN
    END

    DELETE FROM Nhap WHERE manv = @manv
    DELETE FROM Xuat WHERE manv = @manv

    DELETE FROM Nhanvien WHERE manv = @manv

    PRINT 'Đã xóa nhân viên ' + CAST(@manv AS NVARCHAR)
END
go

--Cau 8--
go
CREATE PROCEDURE Cau8
  @masp VARCHAR(10)
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM Sanpham WHERE masp = @masp)
  BEGIN
    PRINT 'Sản phẩm không tồn tại!'
    RETURN;
  END

  BEGIN TRY
    BEGIN TRANSACTION

    DELETE FROM Nhap WHERE masp = @masp;

    DELETE FROM Xuat WHERE masp = @masp;

    DELETE FROM Sanpham WHERE masp = @masp;

    COMMIT TRANSACTION
    PRINT 'Đã xóa sản phẩm thành công' + @masp
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION
go
use QLBanHang
go

--Cau1--
go
CREATE FUNCTION Lab6_C1(@ten AS NVARCHAR(50))
RETURNS TABLE
AS
RETURN
    SELECT sp.masp, sp.tensp, sp.soluong, sp.mausac, sp.giaban, sp.donvitinh, sp.mota, hsx.tenhang
    FROM Sanpham sp
    INNER JOIN Hangsx hsx ON sp.mahangsx = hsx.mahangsx
    WHERE sp.tensp LIKE '%' + @ten + '%'
go
GO
SELECT * FROM Lab6_C1('Galaxy Note 11')
GO

--cau2--
go
CREATE FUNCTION Lab6_C2(@x DATE, @y DATE)
RETURNS TABLE
AS
RETURN 
    SELECT sp.masp, sp.tensp, hsx.tenhang, sp.soluong, sp.mausac, sp.giaban, sp.donvitinh, sp.mota
    FROM Nhap n
    JOIN Sanpham sp ON n.masp = sp.masp
    JOIN Hangsx hsx ON sp.mahangsx = hsx.mahangsx
    WHERE n.ngaynhap BETWEEN @x AND @y
go
GO
SELECT * FROM Lab6_C2('2018-01-01', '2020-12-31')
GO

--cau3--
go
CREATE FUNCTION Lab6_C3 (@hangsx nvarchar(50), @luachon int)
RETURNS TABLE
AS
RETURN
    SELECT sp.masp, sp.tensp, hsx.tenhang, sp.soluong, sp.giaban, sp.donvitinh, sp.mota
    FROM Sanpham sp
    JOIN Hangsx hsx ON sp.mahangsx = hsx.mahangsx
    WHERE hsx.tenhang = @hangsx AND ((@luachon = 0 AND sp.soluong = 0) OR (@luachon = 1 AND sp.soluong > 0))
go
go
SELECT * FROM Lab6_C3('Oppo', 1)
go

--cau4--
go
CREATE FUNCTION Lab6_C4(@tenphong NVARCHAR(50))
RETURNS TABLE
AS
RETURN
    SELECT *
    FROM Nhanvien
    WHERE phong = @tenPhong
go
go
SELECT * FROM Lab6_C4(N'Kế toán')
go

--cau5--
go
CREATE FUNCTION Lab6_C5(@address NVARCHAR(100))
RETURNS TABLE
AS
RETURN
SELECT *
FROM Hangsx
WHERE diachi LIKE '%' + @address + '%'
go
go
SELECT * FROM Lab6_C5(N'Vi')
go

--cau6--
go
CREATE FUNCTION Lab6_C6(@x INT, @y INT)
RETURNS TABLE
AS
RETURN
    SELECT sp.masp, sp.tensp, hsx.tenhang, sp.soluong, sp.mausac, sp.giaban, sp.donvitinh, sp.mota, xuat.ngayxuat
    FROM Sanpham sp
    INNER JOIN Hangsx hsx ON sp.mahangsx = hsx.mahangsx
    INNER JOIN Xuat xuat ON sp.masp = xuat.masp
    WHERE YEAR(xuat.ngayxuat) BETWEEN @x AND @y;
go
go
SELECT * FROM Lab6_C6(2018,2020)
go

--cau7--
go
CREATE FUNCTION Lab6_C7 
(
    @manufacturer_name NVARCHAR(50),
    @option INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT sp.Masp, sp.Tensp, sp.Mausac, sp.Giaban, sp.Donvitinh, sp.Mota
    FROM Sanpham sp
    INNER JOIN Hangsx hs ON sp.Mahangsx = hs.Mahangsx
    LEFT JOIN Nhap n ON sp.Masp = n.Masp
    LEFT JOIN Xuat x ON sp.Masp = x.Masp
    WHERE hs.Tenhang = @manufacturer_name AND
    (
        (@option = 0 AND n.Sohdn IS NOT NULL) OR
        (@option = 1 AND x.Sohdx IS NOT NULL)
    )
	)
go
go
SELECT * FROM Lab6_C7('Samsung',0)
go

--cau 8--
go
CREATE FUNCTION Lab6_C8
(
    @ngayNhap DATE
)
RETURNS TABLE
AS
RETURN 
(
    SELECT 
        nv.manv, 
        nv.tennv, 
        nv.gioitinh, 
        nv.diachi, 
        nv.sodt, 
        nv.email, 
        nv.phong
    FROM 
        Nhanvien nv 
        JOIN Nhap n ON nv.manv = n.manv
    WHERE 
        n.ngaynhap = @ngayNhap
)
go
go
SELECT * FROM Lab6_C8('04-07-2020')
go

--cau 9--
go
CREATE FUNCTION Lab6_C9
(
    @minPrice FLOAT,
    @maxPrice FLOAT,
    @mahangsx VARCHAR(50)
)
PRINT 'Đã xảy ra lỗi trong quá trình xóa sản phẩm!'
  END CATCH
END
go
go 
use QLBanHang
go

-- cau 1--
go
CREATE PROCEDURE Cau_1 (@mahangsx INT, @tenhang VARCHAR(50), @diachi VARCHAR(50), @sodt VARCHAR(15), @email VARCHAR(50))
AS
BEGIN
    IF EXISTS (SELECT * FROM Hangsx WHERE tenhang = @tenhang)
        PRINT N'Đã tồn tại tên hàng.'
    ELSE
        INSERT INTO Hangsx(mahangsx, tenhang, diachi, sodt, email) VALUES (@mahangsx, @tenhang, @diachi, @sodt, @email)
END
go
go
EXEC Cau_1 @mahangsx = 123, @tenhang = N'Oppo1', @diachi = N'Trung Quốc', @sodt = N'0123456789', @email = N'contact@oppo.com'
go

-- cau 2--
go
CREATE PROCEDURE Cau_2
    @masp NVARCHAR(10),
    @mahangsx NVARCHAR(10),
    @tensp NVARCHAR(50),
    @soluong INT,
    @mausac NVARCHAR(20),
    @giaban FLOAT,
    @donvitinh NVARCHAR(20),
    @mota NVARCHAR(200)
AS
BEGIN
    IF EXISTS (SELECT * FROM sanpham WHERE masp = @masp)
    BEGIN
        UPDATE sanpham SET 
            mahangsx = @mahangsx,
            tensp = @tensp,
            soluong = @soluong,
            mausac = @mausac,
            giaban = @giaban,
            donvitinh = @donvitinh,
            mota = @mota
        WHERE masp = @masp
    END
    ELSE
    BEGIN
        INSERT INTO sanpham (masp, mahangsx, tensp, soluong, mausac, giaban, donvitinh, mota)
        VALUES (@masp, @mahangsx, @tensp, @soluong, @mausac, @giaban, @donvitinh, @mota)
    END
END
go

--Cau 3--
go
CREATE PROCEDURE Cau_3
    @tenhang NVARCHAR(50)
AS
BEGIN
 
    IF NOT EXISTS (SELECT * FROM Hangsx WHERE tenhang = @tenhang)
    BEGIN
        PRINT N'Hãng sản xuất không tồn tại '
        RETURN
    END

    BEGIN TRANSACTION

    DELETE FROM Sanpham WHERE mahangsx = (SELECT mahangsx FROM Hangsx WHERE tenhang = @tenhang)


    DELETE FROM Hangsx WHERE tenhang = @tenhang

    COMMIT TRANSACTION
END
go

--Cau 4--
go
CREATE PROCEDURE Cau_4
    @manv VARCHAR(10),
    @tennv NVARCHAR(50),
    @gioitinh NVARCHAR(3),
    @diachi NVARCHAR(100),
    @sodt VARCHAR(20),
    @email NVARCHAR(50),
    @phong NVARCHAR(50),
    @flag BIT
AS
BEGIN
    IF @flag = 0
    BEGIN
        UPDATE Nhanvien
        SET tennv = @tennv,
            gioitinh = @gioitinh,
            diachi = @diachi,
            sodt = @sodt,
            email = @email,
            phong = @phong
        WHERE manv = @manv;
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT * FROM Nhanvien WHERE manv = @manv)
        BEGIN
            RAISERROR('Mã nhân viên đã tồn tại!', 16, 1);
            RETURN;
        END
        INSERT INTO Nhanvien (manv, tennv, gioitinh, diachi, sodt, email, phong)
        VALUES (@manv, @tennv, @gioitinh, @diachi, @sodt, @email, @phong);
    END
END
go

--Cau 5--
go
CREATE PROCEDURE Cau_5(@sohdn varchar(20), @masp varchar(20), @manv varchar(20), @ngaynhap date, @soluongN int, @dongiaN float)
AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        PRINT 'Mã sản phẩm không tồn tại'
        RETURN
END
RETURNS @products TABLE
(
    masp VARCHAR(10),
    mahangsx VARCHAR(10),
    tensp NVARCHAR(50),
    soluong INT,
    mausac NVARCHAR(50),
    giaban FLOAT,
    donvitinh NVARCHAR(20),
    mota NVARCHAR(MAX)
)
AS
BEGIN
    INSERT INTO @products
    SELECT s.masp, s.mahangsx, s.tensp, s.soluong, s.mausac, s.giaban, s.donvitinh, s.mota
    FROM Sanpham s
    INNER JOIN Hangsx h ON s.mahangsx = h.mahangsx
    WHERE s.giaban >= @minPrice AND s.giaban <= @maxPrice AND h.tenhang = @mahangsx
    RETURN
END
go
go
SELECT * FROM Lab6_C9(1,1000000000,'Samsung')
go

--cau10--
go
CREATE FUNCTION Lab6_C_10
(
)
RETURNS TABLE
AS
RETURN
(
    SELECT sp.Masp, sp.Tensp, sp.Mausac, sp.Giaban, sp.Donvitinh, sp.Mota, hs.Tenhang
    FROM Sanpham sp
    INNER JOIN Hangsx hs ON sp.Mahangsx = hs.Mahangsx
)
go

go
SELECT * FROM Lab6_C_10()
go