package com.pigmassacre.postwork;

import com.badlogic.ashley.core.Engine;
import com.badlogic.gdx.Game;
import com.badlogic.gdx.Gdx;
import com.pigmassacre.postwork.screens.GameScreen;

public class PostWork extends Game {

    public Engine engine;

	@Override
	public void create () {
        engine = new Engine();
		setScreen(new GameScreen(this));
	}

	@Override
	public void render () {
        getScreen().render(Gdx.graphics.getDeltaTime());
	}

    @Override
    public void dispose() {
        super.dispose();
    }

}
