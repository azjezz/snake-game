namespace Snake;

use namespace Nuxed\Console;

<<__EntryPoint>>
async function main(): Awaitable<void> {
  require __DIR__.'/../vendor/autoload.hack';
  \Facebook\AutoloadMap\initialize();

  $application = new Console\Application('snake');

  $application->add(new Command\PlayCommand());

  await $application->run();
}
