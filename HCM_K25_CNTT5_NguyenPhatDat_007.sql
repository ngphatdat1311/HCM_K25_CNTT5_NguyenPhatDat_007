

DROP TABLE PATIENTS;
DROP TABLE DOCTORS;
DROP TABLE APPOINTMENTS;
DROP TABLE VISIT_LOG;
DROP TABLE MEDICAL_RECORDS;

-- PHẦN 1: DDL - THIẾT KẾ CSDL
CREATE DATABASE medical_managedb;
use medical_managedb;

CREATE TABLE PATIENTS(
	patient_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) UNIQUE,
    gender VARCHAR(10) NOT NULL,
    date_of_birth TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE PATIENTS
ADD CONSTRAINT ck_date_birth CHECK (date_of_birth < CURRENT_TIMESTAMP);

CREATE TABLE DOCTORS(
	doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
	specialty VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) UNIQUE,
    rating DECIMAL(2,1) DEFAULT 5.0 CHECK (rating BETWEEN 0.0 AND 5.0)
);

CREATE TABLE APPOINTMENTS(
	appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
	appointment_time DATETIME NOT NULL,
    fee DECIMAL(10,0) CHECK(fee >= 0),
    status ENUM('Booked','Completed','Cancelled'),
    FOREIGN KEY (patient_id) REFERENCES PATIENTS(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES DOCTORS(doctor_id)
);

CREATE TABLE VISIT_LOG(
	log_id INT PRIMARY KEY AUTO_INCREMENT,
    record_id INT,
    doctor_id INT,
	log_time DATETIME NOT NULL,
    note TEXT,
    FOREIGN KEY (record_id) REFERENCES MEDICAL_RECORDS(record_id),
    FOREIGN KEY (doctor_id) REFERENCES DOCTORS(doctor_id)
);

CREATE TABLE MEDICAL_RECORDS(
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT,
    symptoms VARCHAR(255) NOT NULL,
    diagnosis VARCHAR(255) NOT NULL,
    prescription TEXT,
    record_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES APPOINTMENTS(appointment_id)
);
-- PHẦN 2: DML - INSERT,UPDATE,DELETE
-- Câu 1: INSERT dữ liệu vào bảng

INSERT INTO PATIENTS VALUE
(1,'Nguyen Thi Lan','0901234567','Female','1999-3-12'),
(2,'Tran Van Minh','0902345678','Male','1996-11-25'),
(3,'Le Hoai Phuong','0913456789','Female','2001-7-8'),
(4,'Pham Duc Anh','0984567890','Male','1998-1-19'),
(5,'Hoang Ngoc Mai','0975678901','Female','2000-9-30');

INSERT INTO DOCTORS VALUE
(1,'BS. Nguyen Van Hai','Noi','0931112223',4.8),
(2,'BS. Tran Thu Ha','Nhi','0932223334',5),
(3,'BS. Le Quoc Tuan','Ngoai','0933334445',4.6),
(4,'BS. Pham Minh Chau','Da lieu','0934445556',4.9),
(5,'BS. Hoang Gia Bao','Tim mach','0935556667',4.7);

INSERT INTO APPOINTMENTS VALUE
(7001,1,1,'2024-05-20 08:00:00',200000,'Booked'),
(7002,2,2,'2024-05-20 09:30:00',250000,'Completed'),
(7003,3,4,'2024-05-20 10:15:00',300000,'Booked'),
(7004,4,5,'2024-05-21 07:00:00',350000,'Completed'),
(7005,5,4,'2024-05-21 08:45:00',220000,'Cancelled');

INSERT INTO MEDICAL_RECORDS VALUE
(8001,7002,'Sốt cao,ho','Viêm họng','Parcetamol + siro ho','2024-05-20 10:00:00'),
(8002,7004,'Đau ngực nhẹ','Theo dõi tim mạch','Vitamin + tái khám','2024-05-21 08:00:00'),
(8003,7001,'Đau bụng','Rối loạn tiêu hóa','Men tiêu hóa','2024-05-20 09:00:00'),
(8004,7003,'Đau vai gáy','Căng cơ','Giảm đau + nghỉ ngơi','2024-05-20 11:00:00'),
(8005,7005,'Ngứa da','Dị ứng','Thuốc bôi ngoài da','2024-05-21 09:00:00');

INSERT INTO VISIT_LOG VALUE
(1,8003,1,'2024-05-20 09:05:00','Đã khám lần đầu'),
(2,8001,2,'2024-05-20 10:05:00','Hoàn tất khám'),
(3,8004,3,'2024-05-20 11:10:00','Tư vấn vật lí trị liệu'),
(4,8002,5,'2024-05-21 08:10:00','Hướng dẫn tái khám'),
(5,8005,4,'2024-05-21 09:05:00','Bệnh nhân hủy hẹn');

-- Câu 2: UPDATE & DELETE

-- Viết câu lệnh tăng 10% phí khám cho các phiếu hẹn thỏa mãn đồng thời:
-- Có trạng thái Completed
-- Thuộc bệnh nhân có năng sinh < 2000
UPDATE APPOINTMENTS a
SET a.fee = a.fee * 1.1
WHERE status = 'Completed' AND a.patient_id IN (SELECT patient_id FROM PATIENTS WHERE date_of_birth < '2000-1-1 00:00:00');



-- Viết câu lệnh xóa các bản ghi trong visit_log thỏa mãn:
-- có log_time trước ngày 20/05/2024
DELETE FROM VISIT_LOG WHERE log_time < '2024-05-20 00:00:00';


-- PHẦN 3: TRUY VẤN CƠ BẢN

-- Câu 1: Liệt kê thông tin bác sĩ gồm full_name, specialty, rating của những bác sĩ có rating > 4.7 HOẶC thuộc chuyên khoa 'Nhi'
SELECT full_name,specialty,rating FROM DOCTORS WHERE rating > 4.7 OR specialty = 'Nhi';

-- Câu 2: Liệt kê các thông tin bệnh nhân gồm full_name, phone_number của những bệnh nhân có ngày sinh trong khoảng từ
-- 1998-01-01 đến 2001-12-31 và số điện thoại bắt đầu từ '090'
SELECT * FROM PATIENTS WHERE (date_of_birth BETWEEN '1988-01-01 00:00:00' AND '2001-12-31 00:00:00') AND phone_number LIKE '090%';

-- Câu 3: Liệt kê các phiếu hẹn gồm appointment_id,appointment_time,fee
-- trong đó danh sách được sắp xếp theo fee giảm dần và chỉ hiển thị 2 phiếu ở trang thứ 2
SELECT appointment_id,appointment_time,fee FROM APPOINTMENTS ORDER BY fee DESC LIMIT 2 OFFSET 2;

-- PHẦN 4: TRUY VẤN NÂNG CAO
-- Câu 1: Liệt kê các thông tin khám gồm họ tên bệnh nhân, họ tên bác sĩ, chuyên khoa, phí khám, thời điểm hẹn khám
-- với dữ liệu được lấy từ các bảng liên quan trong hệ
SELECT p.full_name,d.full_name,d.specialty,a.fee,a.appointment_time FROM PATIENTS p 
JOIN APPOINTMENTS a ON a.patient_id = p.patient_id
JOIN DOCTORS d on d.doctor_id = a.doctor_id;

-- Câu 2: Liệt kê các thông tin bác sĩ gồm họ tên bác sĩ,tổng phí khám mà bác sĩ đó đã thực hiện(chỉ tính phiếu Completed)
-- chỉ hiện thị những bác sĩ có tổng phí lớn hơn 500.000
SElECT d.full_name,tb_total_fee.total_fee FROM DOCTORS d JOIN 
(SELECT doctor_id,sum(fee) as total_fee FROM APPOINTMENTS WHERE status = 'Completed' GROUP BY doctor_id) tb_total_fee 
ON d.doctor_id = tb_total_fee.doctor_id WHERE tb_total_fee.total_fee > 500000;

-- Câu 3: Liệt kê các thông tin bác sĩ gồm doctor_id,full_name,rating của những bác sĩ có điểm đánh giá cao nhất
SELECT doctor_id,full_name,rating FROM DOCTORS WHERE rating = 5.0;

-- PHẦN 5: INDEX & VIEW
-- Câu 1: Tạo chỉ mục trên bảng APPOINTMENTS dựa trên hai thông tin là trạng thái hẹn khám, phí khám nhằm phục vụ tối ưu truy vấn
CREATE INDEX idx_app ON APPOINTMENTS(status,fee);

-- Câu 2: Tạo khung nhìn dữ liệu hiển thị:
-- họ tên bác sĩ,tổng số phiếu hẹn mà bác sĩ đã nhận,tổng doanh thu phí khám mà bác sĩ đó mang lại
-- trong đó không tính các phiếu bị hủy
DROP VIEW view_doctor;
CREATE VIEW view_doctor AS
SELECT d.full_name,IFNULL(tb_dt_ap.total_ap,0) total_ap_dt,IFNULL(tb_dt_ap.total_fee,0) as total_fee_dt FROM DOCTORS d
LEFT JOIN (SELECT a.doctor_id,COUNT(doctor_id) total_ap,SUM(fee) total_fee FROM APPOINTMENTS a WHERE status <> 'Cancelled' GROUP BY a.doctor_id) tb_dt_ap 
ON d.doctor_id = tb_dt_ap.doctor_id;

-- PHẦN 6: TRIGGER
-- Câu 1: Viết một trigger sao cho khi một trạng thái của một phiếu hẹn trong bảng APPOINTMENTS được CẬP NHẬT sang giá trị 'Completed'
-- thì hệ thống tự động thêm một bảng ghi mới vào bảng visit_log với các thông tin sau:
-- appointment_id/recore_id: hồ sơ tương ứng của phiếu vừa cập nhật
-- doctor_id: bác sĩ của phiếu hẹn
-- note: visit completed
-- log_time: thời gian hiện tại của hệ thống
DROP Trigger tg_appointment;
DELIMITER //
CREATE Trigger tg_appointment
AFTER UPDATE ON APPOINTMENTS
FOR EACH ROW
BEGIN
	IF NEW.status = 'Completed' THEN
		INSERT INTO VISIT_LOG(record_id,doctor_id,log_time,note) VALUE
		(NEW.appointment_id,NEW.doctor_id,CURRENT_TIMESTAMP,'Visit Completed');
	END IF;
END //
DELIMITER ;

-- Câu 2: Viết một Trigger sau cho khi thêm một bản ghi vào bảng APPOINTMENTS có trạng thái 'Completed'
-- thì hệ thống tự động tăng điểm đánh giá của bác sĩ tương ứng trong bảng DOCTORS thêm 0.1, nhưng đảm bảo điểm đánh giá không vượt quá 5.0
DROP Trigger tg_dt;
DELIMITER //
CREATE Trigger tg_dt
AFTER INSERT ON APPOINTMENTS
FOR EACH ROW
BEGIN
	IF NEW.status = 'Completed' AND (SELECT rating FROM DOCTORS d WHERE d.doctor_id = NEW.doctor_id) <= 4.9 THEN
		UPDATE DOCTORS d 
        SET rating = rating + 0.1 
        WHERE d.doctor_id = NEW.doctor_id;
	END IF;
END //
DELIMITER ;


-- PHẦN 7: STORED PROCEDURE
-- Câu 1: Viết một stored procedure nhận vào mã bác sĩ và trả về một thông báo kết quả trong đó:
-- nếu tổng phí khám Complete của bác sĩ > 1.000.000 thì trả về High revenue
-- nếu bảng bằng nhau thì trả về Target met
-- nếu nhỏ hơn thì trả về Normal

DROP PROCEDURE pcd_notification;
DELIMITER //
CREATE PROCEDURE pcd_notification(IN p_doctor_id INT,OUT p_notification VARCHAR(100))
BEGIN
	DECLARE p_total_fee INT;
    
	SELECT SUM(fee) INTO p_total_fee FROM APPOINTMENTS a WHERE a.doctor_id = p_doctor_id GROUP BY a.doctor_id;
	CASE
		WHEN p_total_fee > 1000000 THEN SET p_notification = 'High revenue';
		WHEN p_total_fee = 1000000 THEN SET p_notification =  'Target met';
		ELSE SET p_notification =  'Normal';
    end CASE;
END //
DELIMITER ;

-- Câu 2: Viết một stored procedure để thực hiện việc đổi bác sĩ cho một phiếu hẹn khám, gồm các bước sau:
-- b1: bắt đầu quá trình xử lý
-- b2: cập nhật mã bác sĩ mới cho phiếu hẹn trong bảng APPOINTMENTS
-- b3: ghi một bảng ghi mới vào bảng visit_log với ghi chú Doctor reassigned
-- b4: nếu toàn bộ quá trình thành công thì hoàn tất, nếu xảy ra lỗi ở bất kỳ bước nào thì hủy toàn bộ thao tác
DROP PROCEDURE pc_change_doctor;
DELIMITER //
CREATE PROCEDURE pc_change_doctor(p_appointment_id INT,p_new_doctor INT,OUT message VARCHAR(255))
BEGIN
	DECLARE p_record_id INT;
	-- b4
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi, gặp vấn đề ngoài, hãy kiểm tra và chạy lại';
	END;

    -- b1
    START TRANSACTION;
    SELECT recore_id INTO p_record_id FROM MEDICAL_RECORDS m WHERE p_appointment_id = m.appointment_id;
    -- b2
    UPDATE APPOINTMENTS a SET a.doctor_id = p_new_doctor WHERE a.appointment_id = p_appointment_id;
	-- b3
    INSERT INTO visit_log(record_id,doctor_id,log_time,note) VALUE
	(p_record_id,p_new_doctor,CURRENT_TIMESTAMP,'Doctor reassigned');
    -- b4
    COMMIT;
    SET message = 'Cập nhật thành công';
END //
DELIMITER ;


SELECT * FROM PATIENTS;
SELECT * FROM DOCTORS;
SELECT * FROM APPOINTMENTS;
SELECT * FROM VISIT_LOG;
SELECT * FROM MEDICAL_RECORDS;
