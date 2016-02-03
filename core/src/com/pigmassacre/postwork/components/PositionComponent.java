package com.pigmassacre.postwork.components;

import com.badlogic.ashley.core.Component;
import com.badlogic.gdx.utils.Pool;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class PositionComponent implements Component, Pool.Poolable {
    public float x = 0;
    public float y = 0;
    public float previousX = 0;
    public float previousY = 0;

    @Override
    public void reset() {
        x = 0;
        y = 0;
        previousX = 0;
        previousY = 0;
    }
}
