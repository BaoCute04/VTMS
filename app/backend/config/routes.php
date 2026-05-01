<?php

declare(strict_types=1);

use App\Backend\Controllers\AuthController;
use App\Backend\Controllers\DashboardController;
use App\Backend\Controllers\HomeController;
use App\Backend\Core\Route\Router;

return static function (Router $router): void {
    $router->get('/', [HomeController::class, 'index']);

    $router->get('/login', [AuthController::class, 'showLogin']);
    $router->post('/login', [AuthController::class, 'login']);
    $router->post('/logout', [AuthController::class, 'logout'], ['auth']);

    $router->post('/api/auth/login', [AuthController::class, 'apiLogin']);
    $router->post('/api/auth/logout', [AuthController::class, 'apiLogout'], ['auth']);
    $router->get('/api/auth/me', [AuthController::class, 'apiMe'], ['auth']);

    $router->get('/dashboard', [DashboardController::class, 'index'], ['auth']);
    $router->get('/admin', [DashboardController::class, 'admin'], ['auth', 'role:ADMIN']);
    $router->get('/ban-to-chuc', [DashboardController::class, 'organizer'], ['auth', 'role:BAN_TO_CHUC,ADMIN']);
    $router->get('/trong-tai', [DashboardController::class, 'referee'], ['auth', 'role:TRONG_TAI,ADMIN']);
    $router->get('/huan-luyen-vien', [DashboardController::class, 'coach'], ['auth', 'role:HUAN_LUYEN_VIEN,ADMIN']);
    $router->get('/van-dong-vien', [DashboardController::class, 'athlete'], ['auth', 'role:VAN_DONG_VIEN,ADMIN']);
    $router->get('/khan-gia', [DashboardController::class, 'spectator'], ['auth', 'role:KHAN_GIA,ADMIN']);
};
