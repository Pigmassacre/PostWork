package com.pigmassacre.postwork.components;

import com.badlogic.ashley.core.Component;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.utils.Pool;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class VisualComponent implements Component, Pool.Poolable {
    public TextureRegion region;
    public float width = 0f;
    public float height = 0f;

    @Override
    public void reset() {
        region = null;
        width = 0f;
        height = 0f;
    }
}
