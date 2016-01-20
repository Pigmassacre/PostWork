package com.pigmassacre.postwork.input;

import com.badlogic.gdx.Input;
import com.badlogic.gdx.InputAdapter;
import com.badlogic.gdx.ai.msg.MessageManager;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class PlayerInputAdapter extends InputAdapter {

    @Override
    public boolean keyDown(int keycode) {
        switch (keycode) {
            case Input.Keys.LEFT:
                MessageManager.getInstance().dispatchMessage(MessageTypes.MOVE_LEFT);
                return true;
            case Input.Keys.RIGHT:
                MessageManager.getInstance().dispatchMessage(MessageTypes.MOVE_RIGHT);
                return true;
            case Input.Keys.UP:
                MessageManager.getInstance().dispatchMessage(MessageTypes.MOVE_UP);
                return true;
            case Input.Keys.DOWN:
                MessageManager.getInstance().dispatchMessage(MessageTypes.MOVE_DOWN);
                return true;
            case Input.Keys.ENTER:
                MessageManager.getInstance().dispatchMessage(MessageTypes.NEXT_TURN);
                return true;
        }
        return false;
    }
}
