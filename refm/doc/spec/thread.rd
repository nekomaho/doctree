= スレッド

スレッドとはメモリ空間を共有して同時に実行される制御の流れです。
スレッドを使うことで並行プログラミングが可能になります。

現在は Ruby のスレッドはユーザレベルで実装されており、全プラット
ホーム上において同じ挙動を示します。以下、その動作について解説します。

=== Ruby のスレッドの仕様

プログラムの開始と同時に生成されるスレッドをmain threadと呼び
ます。なんらかの理由でmain threadが終了する時には、他の全て
のスレッドもプログラム全体も終了します。ユーザからの割込みによっ
て発生した例外はmain threadに送られます。

スレッドの起動時に指定したブロックの実行が終了するとスレッド
の実行も終了します。ブロックの終了は正常な終了も例外などによ
る異常終了も含みます。

Rubyのスレッドスケジューリングは優先順位付のラウンドロビンです。
一定時間毎、あるいは実行中のスレッドが権利を放棄したタイミングで
スケジューリングが行われ、その時点で実行可能なスレッドのうち最も優先順位
が高いものにコンテキストが移ります。

=== スレッドと例外

あるスレッドで例外が発生し、そのスレッド内でrescueで捕捉されなかった場合、
通常はそのスレッドだけがなにも警告なしに終了されます。ただしその例外で
終了するスレッドを Thread#join で待っている他のスレッドがある場合、
その待っているスレッドに対して、同じ例外が再度発生します。

  begin
    t = Thread.new do
      Thread.pass    # メインスレッドが確実にjoinするように
      raise "unhandled exception"
    end
    t.join
  rescue
    p $!  # => "unhandled exception"
  end

また、以下の3つの方法により、いずれかのスレッドが例外によって終了した時に、
インタプリタ全体を中断させるように指定することができます。

  * スクリプト起動時に -d を指定し、デバッグモードで実行する。
  * Thread.abort_on_exception でフラグを設定する。
  * Thread#abort_on_exception で指定したスレッドのフラグを設定する。

上記3つのいずれかが設定されていた場合、インタプリタ全体が中断されます。
