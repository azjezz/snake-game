namespace Snake\Command;

use namespace Snake;
use namespace Nuxed\{Console, Process};
use namespace Nuxed\Console\Formatter\Style;
use namespace Nuxed\Console\Command;
use namespace Nuxed\Console\Input\Definition;

final class PlayCommand extends Command\Command {
  <<__Override>>
  public function configure(): void {
    $this
      ->setName('play')
      ->setDescription('Play snake game.');
  }

  <<__Override>>
  public async function run(): Awaitable<int> {
    $this->output
      ->getFormatter()
      ->addStyle('snake', new Style\Style(
        Style\BackgroundColor::BLACK,
        Style\ForegroundColor::WHITE,
        vec[Style\Effect::BOLD],
      ))
      ->addStyle('snake-head', new Style\Style(
        Style\BackgroundColor::BLACK,
        Style\ForegroundColor::BLUE,
        vec[Style\Effect::BOLD],
      ))
      ->addStyle('goal', new Style\Style(
        Style\BackgroundColor::BLACK,
        Style\ForegroundColor::MAGENTA,
        vec[Style\Effect::BOLD],
      ))
      ->addStyle('super-goal', new Style\Style(
        Style\BackgroundColor::BLACK,
        Style\ForegroundColor::RED,
        vec[Style\Effect::BOLD, Style\Effect::BLINK],
      ))
      ->addStyle('background', new Style\Style(
        Style\BackgroundColor::BLACK,
        Style\ForegroundColor::CYAN,
      ))
      ->addStyle('border', new Style\Style(
        Style\BackgroundColor::CYAN,
        Style\ForegroundColor::BLACK,
      ))
      ->addStyle('crash', new Style\Style(
        Style\BackgroundColor::BLACK,
        Style\ForegroundColor::RED,
        vec[Style\Effect::BOLD, Style\Effect::BLINK],
      ));

    $height = await Console\Terminal::getHeight();
    $width = await Console\Terminal::getWidth();

    list($mode, $_) = await Process\execute('stty', vec['-g']);
    try {
      await $this->output->getCursor()->hide();

      await Process\execute('stty', vec['-icanon', '-echo']);

      $game = new Snake\Game($width, $height);
      await $game->run($this->input, $this->output);
    } finally {
      await $this->output->getCursor()->show();
      await $this->output->getCursor()->move(0, $height);

      try {
        await Process\execute('stty', vec[$mode]);
      } catch (Process\Exception\IException $_) {
        // ignore.
      }
    }

    await $this->input->getUserInput();

    return Command\ExitCode::SUCCESS;
  }
}
