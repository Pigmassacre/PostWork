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
            case Input.Keys.A:
                MessageManager.getInstance().dispatchMessage(MessageTypes.MOVE_LEFT);
                return true;
            case Input.Keys.RIGHT:
            case Input.Keys.D:
                MessageManager.getInstance().dispatchMessage(MessageTypes.MOVE_RIGHT);
                return true;
            case Input.Keys.UP:
            case Input.Keys.W:
                MessageManager.getInstance().dispatchMessage(MessageTypes.MOVE_UP);
                return true;
            case Input.Keys.DOWN:
            case Input.Keys.S:
                MessageManager.getInstance().dispatchMessage(MessageTypes.MOVE_DOWN);
                return true;
            case Input.Keys.SPACE:
                MessageManager.getInstance().dispatchMessage(MessageTypes.START_SHOOTING);
                return true;
        }
        return false;
    }

    @Override
    public boolean keyUp(int keycode) {
        switch (keycode) {
            case Input.Keys.LEFT:
            case Input.Keys.A:
                MessageManager.getInstance().dispatchMessage(MessageTypes.STOP_MOVE_LEFT);
                return true;
            case Input.Keys.RIGHT:
            case Input.Keys.D:
                MessageManager.getInstance().dispatchMessage(MessageTypes.STOP_MOVE_RIGHT);
                return true;
            case Input.Keys.UP:
            case Input.Keys.W:
                MessageManager.getInstance().dispatchMessage(MessageTypes.STOP_MOVE_UP);
                return true;
            case Input.Keys.DOWN:
            case Input.Keys.S:
                MessageManager.getInstance().dispatchMessage(MessageTypes.STOP_MOVE_DOWN);
                return true;
            case Input.Keys.SPACE:
                MessageManager.getInstance().dispatchMessage(MessageTypes.STOP_SHOOTING);
                return true;
        }
        return false;
    }
}
