package com.pigmassacre.postwork.components;

import com.badlogic.ashley.core.Component;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.utils.Pool;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class VisualComponent implements Component, Pool.Poolable {
    public TextureRegion region;

    @Override
    public void reset() {
        region = null;
    }
}
