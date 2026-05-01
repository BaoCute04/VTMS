# VTMS

VTMS la ung dung quan ly giai dau bong chuyen theo kien truc Monolithic MVC + Service Layer.

## Cau truc hien tai

- `public/index.php`: Front Controller, diem vao duy nhat cua ung dung.
- `app/backend/bootstrap.php`: khoi tao config, session, autoload, database va router.
- `app/backend/config`: cau hinh ung dung, CSDL va routes.
- `app/backend/core`: cac lop nen tang nhu Router, Request, Response, View, Database, Auth, Middleware.
- `app/backend/controllers`: controller dieu phoi request.
- `app/backend/services`: xu ly nghiep vu.
- `app/backend/models`: truy cap du lieu.
- `app/frontend/views`: giao dien theo module.
- `app/frontend/layout`: layout dung chung.

## Chay ung dung

Can PHP 8.1+ va MySQL neu muon ket noi CSDL thuc.

```powershell
cd d:\Tai_Lieu_IUH\Tailieu_Nam4_HK2\CongNgheMoi\VTMS\VTMS
php -S localhost:8000 -t public public/server.php
```

Mo trinh duyet tai:

```text
http://localhost:8000
```

## Tai khoan mau

Sau khi import `VTMS_mysql_script_new.sql`, co the dang nhap bang cac tai khoan mau:

- `admin01 / 123456`
- `btc01 / 123456`
- `tt01 / 123456`
- `hlv01 / 123456`
- `vdv01 / 123456`
- `khangia01 / 123456`

## Viec can lam tiep

1. Gan ket CSDL that voi model/service.
2. Hoan thien module tai khoan va phan quyen.
3. Hien thuc module giai dau, doi bong, dang ky, lich thi dau, ket qua va thong ke.
4. Bo sung validation, flash message, logging va test.
