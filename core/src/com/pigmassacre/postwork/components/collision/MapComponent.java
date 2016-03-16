package com.pigmassacre.postwork.components.collision;

import com.badlogic.ashley.core.Component;
import com.badlogic.gdx.math.Rectangle;
import com.badlogic.gdx.utils.Pool;

/**
 * Created by pigmassacre on 2016-02-03.
 */
public class MapComponent implements Component, Pool.Poolable {
    public Rectangle rectangle;

    public void init(float width, float height) {
        this.rectangle = new Rectangle(0f, 0f, width, height);
    }

    @Override
    public void reset() {
        this.rectangle = null;
    }
}
