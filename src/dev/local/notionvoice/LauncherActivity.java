package dev.local.notionvoice;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

/**
 * Notion AI の音声入力モードを直接開くための中継アクティビティ。
 *
 * <p>画面を一切表示せず、起動と同時に Notion へインテントを投げて即座に終了する。
 * 電源ボタン2回押し・Essential Key・デジタルアシスタント枠のいずれからも同じ動作をする。
 *
 * <p>画面ロック中に起動された場合、本アクティビティはシステムによってロック解除まで
 * 保留され、解除された時点で onCreate が走って Notion が開く。
 * ロック解除そのものをアプリ側で省略することはできない（OS の制約）。
 * 解除操作なしで到達したい場合は Smart Lock を利用する。
 *
 * <p>なお {@code showWhenLocked} でロック画面より前面に出し
 * {@code requestDismissKeyguard} を呼ぶ方式も検証したが、認証を省略できないうえに
 * ロック画面が隠れて解除しづらくなるため採用していない。
 */
public class LauncherActivity extends Activity {

    /** Notion が公開している「Notion AI を開く」インテントアクション。 */
    private static final String ACTION_OPEN_NOTION_AI = "notion.local.id.OPEN_NOTION_AI";

    /** 入力モードを指定する extra のキー。 */
    private static final String EXTRA_INPUT_MODE = "input_mode";

    /** 音声入力モードを表す値。これを渡すと録音状態で開く。 */
    private static final String INPUT_MODE_VOICE = "voice";

    /** Notion のパッケージ名。 */
    private static final String NOTION_PACKAGE = "notion.id";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent intent = new Intent(ACTION_OPEN_NOTION_AI);
        intent.setPackage(NOTION_PACKAGE);
        intent.putExtra(EXTRA_INPUT_MODE, INPUT_MODE_VOICE);
        // Notion 側を独立したタスクの最前面に出す
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        try {
            startActivity(intent);
        } catch (ActivityNotFoundException e) {
            // Notion が未インストール、または対応バージョンでない場合
            Toast.makeText(this, R.string.error_notion_not_found, Toast.LENGTH_LONG).show();
        }

        // Theme.NoDisplay を使うため、onCreate 内で必ず終了させる
        finish();
    }
}
