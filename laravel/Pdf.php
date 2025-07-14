<?php

namespace App\Actions\Helpers;

class Pdf
{
    /**
     * Gets a configured instance of Browsershot
     *
     * @param  string  $html  (A string of the HTML to render)
     */
    public function __invoke(string $html)
    {
        // Create unique user data directory for this instance
        $uniqueUserDataDir = '/tmp/chrome-user-data-'.uniqid();

        return \Spatie\Browsershot\Browsershot::html($html)
            ->noSandbox()
            ->setNodeBinary(config('services.browsershot.node_binary', '/usr/bin/node'))
            ->setNpmBinary(config('services.browsershot.npm_binary', '/usr/bin/npm'))
            ->setNodeModulePath(config('services.browsershot.node_modules_path', '/usr/lib/node_modules'))
            ->waitUntilNetworkIdle()
            ->setOption('args', [
                '--disable-web-security',
                "--user-data-dir={$uniqueUserDataDir}",
                '--disable-dev-shm-usage',
                '--disable-extensions',
                '--no-first-run',
                '--disable-features=VizDisplayCompositor,AudioServiceOutOfProcess',
                '--disable-crash-reporter',
                '--disable-breakpad',
                '--headless=new',
                '--disable-gpu',
                '--remote-debugging-port=0',
            ])
            ->addChromiumArguments([
                'font-render-hinting' => 'none',
            ])
            ->setOption('env', [
                'HOME' => '/var/www',
                'TMPDIR' => '/tmp',
            ]);
    }
}
