package com.pigmassacre.postwork.input;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.controllers.Controller;
import com.badlogic.gdx.controllers.ControllerListener;
import com.badlogic.gdx.controllers.PovDirection;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector3;
import com.pigmassacre.postwork.components.JoystickControllerComponent;
import com.pigmassacre.postwork.managers.EntityCreator;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class ControllerInputAdapter extends EntityController implements ControllerListener {

    @Override
    public boolean axisMoved(Controller controller, int axisIndex, float value) {
        if (getControlledEntity() != null) {
            JoystickControllerComponent joystick = Mappers.joystickController.get(getControlledEntity());
            if (Math.abs(value) > 0.1f) {
                joystick.axes[axisIndex] = value;
            } else {
                joystick.axes[axisIndex] = 0f;
            }
            return true;
        }
        return false;
    }

    @Override
    public boolean povMoved(Controller controller, int povCode, PovDirection value) {
        return false;
    }

    @Override
    public boolean xSliderMoved(Controller controller, int sliderCode, boolean value) {
        return false;
    }

    @Override
    public boolean ySliderMoved(Controller controller, int sliderCode, boolean value) {
        return false;
    }

    @Override
    public boolean accelerometerMoved(Controller controller, int accelerometerCode, Vector3 value) {
        return false;
    }

    @Override
    public void connected(Controller controller) {
        Gdx.app.log("Controllers", "Controller connected: " + controller.getName());
    }

    @Override
    public void disconnected(Controller controller) {
        Gdx.app.log("Controllers", "Controller disconnected: " + controller.getName());
    }

    @Override
    public boolean buttonDown(Controller controller, int buttonIndex) {
        Gdx.app.log("Button Down", String.valueOf(buttonIndex));
        switch (buttonIndex) {
            case 1:
                MessageManager.getInstance().dispatchMessage(MessageTypes.PAUSE_SHOOTING);
                break;
        }
        return false;
    }

    @Override
    public boolean buttonUp(Controller controller, int buttonIndex) {
        Gdx.app.log("Button Up", String.valueOf(buttonIndex));
        switch (buttonIndex) {
            case 1:
                MessageManager.getInstance().dispatchMessage(MessageTypes.UNPAUSE_SHOOTING);
                break;
            case 0:
                EntityCreator.createHomingEnemy(MathUtils.random(-150, 150), MathUtils.random(-150, 150), 5, 5, getControlledEntity());
                break;
        }
        return false;
    }
}
