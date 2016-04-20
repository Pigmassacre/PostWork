package com.pigmassacre.postwork.input;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.InputAdapter;
import com.badlogic.gdx.InputProcessor;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.scenes.scene2d.InputListener;
import com.pigmassacre.postwork.components.JoystickControllerComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class PlayerInputAdapter extends EntityController implements InputProcessor {

    @Override
    public boolean keyDown(int keycode) {
        Entity controlledEntity = getControlledEntity();
        JoystickControllerComponent joystick = null;
        if (controlledEntity != null) {
            joystick = Mappers.joystickController.get(controlledEntity);
        }
        switch (keycode) {
            case Input.Keys.LEFT:
            case Input.Keys.A:
                if (joystick != null) {
                    joystick.axes[0] = -1;
                }
                MessageManager.getInstance().dispatchMessage(MessageTypes.MOVE_LEFT);
                return true;
            case Input.Keys.RIGHT:
            case Input.Keys.D:
                if (joystick != null) {
                    joystick.axes[0] = 1;
                }
                MessageManager.getInstance().dispatchMessage(MessageTypes.MOVE_RIGHT);
                return true;
            case Input.Keys.UP:
            case Input.Keys.W:
                if (joystick != null) {
                    joystick.axes[1] = -1;
                }
                MessageManager.getInstance().dispatchMessage(MessageTypes.MOVE_UP);
                return true;
            case Input.Keys.DOWN:
            case Input.Keys.S:
                if (joystick != null) {
                    joystick.axes[1] = 1;
                }
                MessageManager.getInstance().dispatchMessage(MessageTypes.MOVE_DOWN);
                return true;
            case Input.Keys.ALT_RIGHT:
                if (joystick != null) {
                    joystick.axes[5] = 6;
                }
                return true;
            case Input.Keys.SPACE:
                MessageManager.getInstance().dispatchMessage(MessageTypes.START_SHOOTING);
                return true;
        }
        return false;
    }

    @Override
    public boolean keyUp(int keycode) {
        Entity controlledEntity = getControlledEntity();
        JoystickControllerComponent joystick = null;
        if (controlledEntity != null) {
            joystick = Mappers.joystickController.get(controlledEntity);
        }
        switch (keycode) {
            case Input.Keys.LEFT:
            case Input.Keys.A:
                if (joystick != null) {
                    joystick.axes[0] = 0;
                }
                MessageManager.getInstance().dispatchMessage(MessageTypes.STOP_MOVE_LEFT);
                return true;
            case Input.Keys.RIGHT:
            case Input.Keys.D:
                if (joystick != null) {
                    joystick.axes[0] = 0;
                }
                MessageManager.getInstance().dispatchMessage(MessageTypes.STOP_MOVE_RIGHT);
                return true;
            case Input.Keys.UP:
            case Input.Keys.W:
                if (joystick != null) {
                    joystick.axes[1] = 0;
                }
                MessageManager.getInstance().dispatchMessage(MessageTypes.STOP_MOVE_UP);
                return true;
            case Input.Keys.DOWN:
            case Input.Keys.S:
                if (joystick != null) {
                    joystick.axes[1] = 0;
                }
                MessageManager.getInstance().dispatchMessage(MessageTypes.STOP_MOVE_DOWN);
                return true;
            case Input.Keys.ALT_RIGHT:
                if (joystick != null) {
                    joystick.axes[5] = 0;
                }
                return true;
            case Input.Keys.SPACE:
                MessageManager.getInstance().dispatchMessage(MessageTypes.STOP_SHOOTING);
                return true;
        }
        return false;
    }

    @Override
    public boolean keyTyped(char character) {
        return false;
    }

    @Override
    public boolean touchDown(int screenX, int screenY, int pointer, int button) {
        return false;
    }

    @Override
    public boolean touchUp(int screenX, int screenY, int pointer, int button) {
        return false;
    }

    @Override
    public boolean touchDragged(int screenX, int screenY, int pointer) {
        return false;
    }

    @Override
    public boolean mouseMoved(int screenX, int screenY) {
        return false;
    }

    @Override
    public boolean scrolled(int amount) {
        return false;
    }
}
