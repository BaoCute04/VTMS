<?php

declare(strict_types=1);

namespace App\Backend\Core\Route;

use App\Backend\Core\Http\Request;
use App\Backend\Core\Http\Response;
use App\Backend\Core\View;
use Throwable;

final class Router
{
    private array $routes = [];
    private array $middlewareAliases = [];

    public function get(string $path, callable|array|string $handler, array $middleware = []): void
    {
        $this->add('GET', $path, $handler, $middleware);
    }

    public function post(string $path, callable|array|string $handler, array $middleware = []): void
    {
        $this->add('POST', $path, $handler, $middleware);
    }

    public function add(string $method, string $path, callable|array|string $handler, array $middleware = []): void
    {
        [$pattern, $params] = $this->compilePath($path);

        $this->routes[strtoupper($method)][] = [
            'path' => $path,
            'pattern' => $pattern,
            'params' => $params,
            'handler' => $handler,
            'middleware' => $middleware,
        ];
    }

    public function aliasMiddleware(string $alias, string $class): void
    {
        $this->middlewareAliases[$alias] = $class;
    }

    public function dispatch(?Request $request = null): void
    {
        $request ??= Request::capture();

        try {
            $route = $this->match($request);

            if ($route === null) {
                View::render('errors.404', ['path' => $request->path()], 'main', 404)->send();
                return;
            }

            $request = $request->withRouteParams($route['routeParams']);
            $response = $this->runPipeline($request, $route);
            $this->send($response);
        } catch (Throwable $exception) {
            if ((bool) config('app.debug', false)) {
                throw $exception;
            }

            View::render('errors.500', [], 'main', 500)->send();
        }
    }

    private function match(Request $request): ?array
    {
        foreach ($this->routes[$request->method()] ?? [] as $route) {
            if (!preg_match($route['pattern'], $request->path(), $matches)) {
                continue;
            }

            $params = [];

            foreach ($route['params'] as $name) {
                $params[$name] = $matches[$name] ?? null;
            }

            $route['routeParams'] = $params;

            return $route;
        }

        return null;
    }

    private function runPipeline(Request $request, array $route): mixed
    {
        $next = fn (Request $request): mixed => $this->runHandler($route['handler'], $request);

        foreach (array_reverse($route['middleware']) as $middleware) {
            $next = function (Request $request) use ($middleware, $next): mixed {
                [$class, $params] = $this->resolveMiddleware($middleware);
                $instance = new $class();

                return $instance->handle($request, $next, ...$params);
            };
        }

        return $next($request);
    }

    private function runHandler(callable|array|string $handler, Request $request): mixed
    {
        if (is_array($handler) && is_string($handler[0])) {
            $handler[0] = new $handler[0]();
        }

        if (is_string($handler) && str_contains($handler, '@')) {
            [$class, $method] = explode('@', $handler, 2);
            $handler = [new $class(), $method];
        }

        return $handler($request);
    }

    private function send(mixed $response): void
    {
        if ($response instanceof Response) {
            $response->send();
            return;
        }

        echo (string) $response;
    }

    private function resolveMiddleware(string $middleware): array
    {
        [$name, $params] = array_pad(explode(':', $middleware, 2), 2, '');
        $class = $this->middlewareAliases[$name] ?? $name;
        $params = $params === '' ? [] : array_map('trim', explode(',', $params));

        return [$class, $params];
    }

    private function compilePath(string $path): array
    {
        $params = [];
        $pattern = preg_replace_callback('/\{([a-zA-Z_][a-zA-Z0-9_]*)}/', static function (array $matches) use (&$params): string {
            $params[] = $matches[1];
            return '(?P<' . $matches[1] . '>[^/]+)';
        }, '/' . trim($path, '/'));

        if ($pattern === '') {
            $pattern = '/';
        }

        return ['#^' . $pattern . '$#', $params];
    }
}
