USE qlsinhvien;

DELIMITER // 
CREATE PROCEDURE sp_XepLoaiSinhVienTheoDiemTB(
	IN p_MaSV VARCHAR(10),
    OUT p_ThongBao VARCHAR(100)
)
BEGIN
	DECLARE DiemTB FLOAT;
    SELECT ROUND(AVG(d.diem),2) INTO DiemTB
    FROM SinhVien AS sv
    LEFT JOIN Diem AS d ON sv.MaSV = d.MaSV
    WHERE sv.MaSV = p_MaSV;
    IF DiemTB > 8.5 THEN
		SET p_ThongBao = 'Xuất sắc - Học bổng cao';
	ELSEIF DiemTB > 8.0 THEN
		SET p_ThongBao = 'Target met - Giỏi';
	ELSEIF DiemTB IS NULL THEN
		SET p_ThongBao = 'Chưa có dữ liệu điểm';
	ELSE 
		SET p_ThongBao = 'Cần nỗ lực thêm';
	END IF;
END
// DELIMITER ;

CALL sp_XepLoaiSinhVienTheoDiemTB('SV001', @msg);
SELECT @msg;

-- ---------------------------------------------------------------------------------------- --

DELIMITER //
CREATE PROCEDURE sp_DangKyMonHoc(
    IN p_MaSV VARCHAR(10),
    IN p_MaMH VARCHAR(10),
    OUT p_ThongBao VARCHAR(100)
)
BEGIN
    DECLARE v_Count INT;

    SELECT COUNT(*) INTO v_Count
    FROM Diem
    WHERE MaSV = p_MaSV AND MaMH = p_MaMH;

    IF v_Count > 0 THEN
        SET p_ThongBao = 'Sinh viên đã đăng ký môn này!';
    ELSE
        INSERT INTO Diem(MaSV, MaMH, Diem, LanThi, NgayThi)
        VALUES(p_MaSV, p_MaMH, 0, 1, CURDATE());
        SET p_ThongBao = 'Đăng ký môn học thành công!';
    END IF;
END
// 
DELIMITER ;

CALL sp_DangKyMonHoc('SV001', 'MH001', @msg);
SELECT @msg;

-- ---------------------------------------------------------------------------------------- --

DELIMITER //
CREATE PROCEDURE sp_CapNhatDiem(
    IN p_MaSV VARCHAR(10),
    IN p_MaMH VARCHAR(10),
    IN p_DiemMoi FLOAT,
    OUT p_ThongBao VARCHAR(100)
)
BEGIN
    DECLARE v_Count INT;

    IF p_DiemMoi < 0 OR p_DiemMoi > 10 THEN
        SET p_ThongBao = 'Điểm không hợp lệ!';
    ELSE
        SELECT COUNT(*) INTO v_Count
        FROM Diem
        WHERE MaSV = p_MaSV AND MaMH = p_MaMH;

        IF v_Count = 0 THEN
            SET p_ThongBao = 'Sinh viên chưa đăng ký môn học này!';
        ELSE
            UPDATE Diem
            SET Diem = p_DiemMoi
            WHERE MaSV = p_MaSV AND MaMH = p_MaMH;

            SET p_ThongBao = 'Cập nhật điểm thành công!';
        END IF;
    END IF;
END
// 
DELIMITER ;

CALL sp_CapNhatDiem('SV001', 'MH001', 8.5, @msg);
SELECT @msg;

-- ---------------------------------------------------------------------------------------- --

DELIMITER //
CREATE PROCEDURE sp_ThongKeSinhVienKhoa(
    IN p_MaKhoa VARCHAR(10),
    OUT p_SoSinhVien INT,
    OUT p_DiemTB FLOAT,
    OUT p_ThongBao VARCHAR(100)
)
BEGIN
    DECLARE v_TenKhoa VARCHAR(50);

    SELECT COUNT(*) INTO p_SoSinhVien
    FROM SinhVien
    WHERE MaKhoa = p_MaKhoa;

    SELECT ROUND(AVG(d.Diem),2) INTO p_DiemTB
    FROM Diem AS d
    JOIN SinhVien AS sv ON d.MaSV = sv.MaSV
    WHERE sv.MaKhoa = p_MaKhoa;

    SELECT TenKhoa INTO v_TenKhoa
    FROM Khoa
    WHERE MaKhoa = p_MaKhoa;

    SET p_ThongBao = CONCAT('Khoa ', v_TenKhoa, 
                            ' có ', p_SoSinhVien, 
                            ' sinh viên, điểm TB: ', p_DiemTB);
END
// 
DELIMITER ;

CALL sp_ThongKeSinhVienKhoa('CNTT', @sosv, @dtb, @msg);
SELECT @sosv, @dtb, @msg;