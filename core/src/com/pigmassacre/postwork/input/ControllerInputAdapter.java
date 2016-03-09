package com.pigmassacre.postwork.input;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.InputAdapter;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.controllers.Controller;
import com.badlogic.gdx.controllers.ControllerAdapter;
import com.pigmassacre.postwork.components.JoystickControllerComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class ControllerInputAdapter extends ControllerAdapter {

    private Entity controlledEntity;

    public Entity getControlledEntity() {
        return controlledEntity;
    }

    public void setControlledEntity(Entity controlledEntity) {
        this.controlledEntity = controlledEntity;
    }

    @Override
    public boolean axisMoved(Controller controller, int axisIndex, float value) {
        if (controlledEntity != null) {
            JoystickControllerComponent joystick = Mappers.joystickController.get(controlledEntity);
            if (Math.abs(value) > 0.1f) {
                Gdx.app.log("Controllers: Axis", String.valueOf(axisIndex));
                Gdx.app.log("Controllers: Value", String.valueOf(value));
                joystick.axes[axisIndex] = value;
            } else {
                joystick.axes[axisIndex] = 0f;
            }
            return true;
        }
        return false;
    }

    @Override
    public boolean buttonDown(Controller controller, int buttonIndex) {
        Gdx.app.log("Controllers", String.valueOf(buttonIndex));
        switch (buttonIndex) {
            default:
                MessageManager.getInstance().dispatchMessage(MessageTypes.START_SHOOTING);
                MessageManager.getInstance().dispatchMessage(MessageTypes.STOP_SHOOTING);
                break;
        }
        return false;
    }

}
