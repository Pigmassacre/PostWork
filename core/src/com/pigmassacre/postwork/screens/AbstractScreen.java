package com.pigmassacre.postwork.screens;

import com.badlogic.gdx.InputMultiplexer;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.utils.viewport.Viewport;
import com.pigmassacre.postwork.PostWork;

/**
 * Created by pigmassacre on 2016-01-13.
 */
public class AbstractScreen implements Screen {

    final PostWork game;
    final InputMultiplexer inputMultiplexer;

    Viewport viewport;

    public AbstractScreen(PostWork game) {
        this.game = game;
        inputMultiplexer = new InputMultiplexer();
    }


    @Override
    public void show() {

    }

    @Override
    public void render(float delta) {

    }

    @Override
    public void resize(int width, int height) {
        if (viewport != null) {
            viewport.update(width, height   );
        }
    }

    @Override
    public void pause() {

    }

    @Override
    public void resume() {

    }

    @Override
    public void hide() {

    }

    @Override
    public void dispose() {

    }
}
