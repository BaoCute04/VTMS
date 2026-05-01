<?php

declare(strict_types=1);

namespace App\Backend\Core\Middleware;

use App\Backend\Core\Auth\Auth;
use App\Backend\Core\Http\Request;
use App\Backend\Core\Http\Response;
use App\Backend\Core\View;

final class RoleMiddleware
{
    public function handle(Request $request, callable $next, string ...$roles): mixed
    {
        if (!Auth::check()) {
            return Response::redirect('/login');
        }

        if (!Auth::hasRole($roles)) {
            return View::render('errors.403', [
                'role' => Auth::role(),
                'requiredRoles' => $roles,
            ], 'main', 403);
        }

        return $next($request);
    }
}
