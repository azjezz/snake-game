namespace Snake\Command;

use namespace Snake;
use namespace Nuxed\{Console, Process};
use namespace Nuxed\Console\Formatter\Style;
use namespace Nuxed\Console\Command;

final class PlayCommand extends Command\Command {
  <<__Override>>
  public function configure(): void {
    $this
      ->setName('play')
      ->setDescription('Play snake game.');
  }

  <<__Override>>
  public async function run(): Awaitable<int> {
    $this->output->getFormatter()->addStyle('snake', new Style\Style(
      Style\BackgroundColor::BLACK,
      Style\ForegroundColor::GREEN,
      vec[Style\Effect::BOLD],
    ));
    $this->output->getFormatter()->addStyle('goal', new Style\Style(
      Style\BackgroundColor::BLACK,
      Style\ForegroundColor::MAGENTA,
      vec[Style\Effect::BOLD],
    ));
    $this->output->getFormatter()->addStyle('super-goal', new Style\Style(
      Style\BackgroundColor::BLACK,
      Style\ForegroundColor::RED,
      vec[Style\Effect::BOLD, Style\Effect::BLINK],
    ));
    $this->output->getFormatter()->addStyle('background', new Style\Style(
      Style\BackgroundColor::BLACK,
      Style\ForegroundColor::CYAN,
    ));
    $this->output->getFormatter()->addStyle('footer', new Style\Style(
      Style\BackgroundColor::CYAN,
      Style\ForegroundColor::WHITE,
    ));
    $this->output->getFormatter()->addStyle('crash', new Style\Style(
      Style\BackgroundColor::BLACK,
      Style\ForegroundColor::RED,
      vec[Style\Effect::BOLD, Style\Effect::BLINK],
    ));

    list($mode, $_) = await Process\execute('stty', vec['-g']);
    await Process\execute('stty', vec['-icanon', '-echo']);

    await $this->output->getCursor()->hide();

    $game = new Snake\Game(
      await Console\Terminal::getWidth(),
      await Console\Terminal::getHeight(),
    );

    await $game->run($this->input, $this->output);

    await $this->output->getCursor()->show();
    try {
      await Process\execute('stty', vec[$mode]);
    } catch (Process\Exception\IException $_) {
      // ignore.
    }

    return Command\ExitCode::SUCCESS;
  }
}
