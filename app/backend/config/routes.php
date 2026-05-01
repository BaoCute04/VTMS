<?php

declare(strict_types=1);

use App\Backend\Controllers\AuthController;
use App\Backend\Controllers\AdminAccountController;
use App\Backend\Controllers\AdminUserController;
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
    $router->get('/admin/users', [AdminAccountController::class, 'page'], ['auth', 'role:ADMIN']);
    $router->get('/admin/nguoi-dung', [AdminUserController::class, 'page'], ['auth', 'role:ADMIN']);

    $router->get('/api/admin/roles', [AdminAccountController::class, 'roles'], ['auth', 'role:ADMIN']);
    $router->get('/api/admin/accounts', [AdminAccountController::class, 'index'], ['auth', 'role:ADMIN']);
    $router->post('/api/admin/accounts', [AdminAccountController::class, 'store'], ['auth', 'role:ADMIN']);
    $router->get('/api/admin/accounts/{id}', [AdminAccountController::class, 'show'], ['auth', 'role:ADMIN']);
    $router->add('PUT', '/api/admin/accounts/{id}', [AdminAccountController::class, 'update'], ['auth', 'role:ADMIN']);
    $router->add('PATCH', '/api/admin/accounts/{id}', [AdminAccountController::class, 'update'], ['auth', 'role:ADMIN']);
    $router->post('/api/admin/accounts/{id}/update', [AdminAccountController::class, 'update'], ['auth', 'role:ADMIN']);
    $router->add('DELETE', '/api/admin/accounts/{id}', [AdminAccountController::class, 'destroy'], ['auth', 'role:ADMIN']);
    $router->post('/api/admin/accounts/{id}/delete', [AdminAccountController::class, 'destroy'], ['auth', 'role:ADMIN']);

    $router->get('/api/admin/users', [AdminUserController::class, 'index'], ['auth', 'role:ADMIN']);
    $router->get('/api/admin/users/{id}', [AdminUserController::class, 'show'], ['auth', 'role:ADMIN']);
    $router->add('PUT', '/api/admin/users/{id}', [AdminUserController::class, 'update'], ['auth', 'role:ADMIN']);
    $router->add('PATCH', '/api/admin/users/{id}', [AdminUserController::class, 'update'], ['auth', 'role:ADMIN']);
    $router->post('/api/admin/users/{id}/update', [AdminUserController::class, 'update'], ['auth', 'role:ADMIN']);

    $router->get('/ban-to-chuc', [DashboardController::class, 'organizer'], ['auth', 'role:BAN_TO_CHUC,ADMIN']);
    $router->get('/trong-tai', [DashboardController::class, 'referee'], ['auth', 'role:TRONG_TAI,ADMIN']);
    $router->get('/huan-luyen-vien', [DashboardController::class, 'coach'], ['auth', 'role:HUAN_LUYEN_VIEN,ADMIN']);
    $router->get('/van-dong-vien', [DashboardController::class, 'athlete'], ['auth', 'role:VAN_DONG_VIEN,ADMIN']);
    $router->get('/khan-gia', [DashboardController::class, 'spectator'], ['auth', 'role:KHAN_GIA,ADMIN']);
};
