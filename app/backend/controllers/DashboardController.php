<?php

declare(strict_types=1);

namespace App\Backend\Controllers;

use App\Backend\Core\Auth\Auth;
use App\Backend\Core\Controller;
use App\Backend\Core\Http\Request;
use App\Backend\Core\Http\Response;

final class DashboardController extends Controller
{
    public function index(Request $request): Response
    {
        return $this->view('dashboard.index', [
            'user' => Auth::user(),
            'moduleTitle' => 'Tong quan he thong',
            'moduleDescription' => 'Man hinh dieu huong ban dau theo vai tro nguoi dung.',
        ]);
    }

    public function admin(Request $request): Response
    {
        return $this->module('Quan tri he thong', 'Quan ly tai khoan, vai tro, cau hinh va nhat ky.');
    }

    public function organizer(Request $request): Response
    {
        return $this->module('Ban to chuc', 'Quan ly giai dau, dieu le, doi bong, lich thi dau va ket qua.');
    }

    public function referee(Request $request): Response
    {
        return $this->module('Trong tai', 'Xem phan cong, ghi nhan su kien tran dau va bao cao su co.');
    }

    public function coach(Request $request): Response
    {
        return $this->module('Huan luyen vien', 'Quan ly doi bong, thanh vien, dang ky giai va doi hinh.');
    }

    public function athlete(Request $request): Response
    {
        return $this->module('Van dong vien', 'Theo doi ho so, lich thi dau, loi moi va don nghi phep.');
    }

    public function spectator(Request $request): Response
    {
        return $this->module('Khan gia', 'Theo doi doi bong, lich thi dau, ket qua va bang xep hang.');
    }

    private function module(string $title, string $description): Response
    {
        return $this->view('dashboard.index', [
            'user' => Auth::user(),
            'moduleTitle' => $title,
            'moduleDescription' => $description,
        ]);
    }
}
