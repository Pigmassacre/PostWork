package com.pigmassacre.postwork.screens;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.freetype.FreeTypeFontGenerator;
import com.badlogic.gdx.math.Interpolation;
import com.badlogic.gdx.scenes.scene2d.Stage;
import static com.badlogic.gdx.scenes.scene2d.actions.Actions.*;

import com.badlogic.gdx.scenes.scene2d.actions.FloatAction;
import com.badlogic.gdx.scenes.scene2d.actions.IntAction;
import com.badlogic.gdx.scenes.scene2d.actions.RunnableAction;
import com.badlogic.gdx.scenes.scene2d.actions.SizeByAction;
import com.badlogic.gdx.scenes.scene2d.ui.Container;
import com.badlogic.gdx.scenes.scene2d.ui.Label;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.scenes.scene2d.ui.TextArea;
import com.badlogic.gdx.utils.Align;
import com.badlogic.gdx.utils.viewport.ScreenViewport;
import com.pigmassacre.postwork.PostWork;
import com.pigmassacre.postwork.managers.GameManager;

/**
 * Created by pigmassacre on 2016-01-13.
 */
public class StartScreen extends AbstractScreen {

    OrthographicCamera camera;
    Stage stage;
    Table root;

    public StartScreen(PostWork game) {
        super(game);

        GameManager.setGame(game);

        camera = new OrthographicCamera(Gdx.graphics.getWidth(), Gdx.graphics.getHeight());

        stage = new Stage();

        stage.setViewport(new ScreenViewport());

        Gdx.input.setInputProcessor(stage);

        root = new Table();
        root.setFillParent(true);
        stage.addActor(root);

        FreeTypeFontGenerator generator = new FreeTypeFontGenerator(Gdx.files.internal("fonts/vermin_vibes_1989.ttf"));
        FreeTypeFontGenerator.FreeTypeFontParameter parameter = new FreeTypeFontGenerator.FreeTypeFontParameter();
        parameter.size = 36;
        BitmapFont bitmapFont = generator.generateFont(parameter);
        generator.dispose(); // don't forget to dispose to avoid memory leaks!

        final Label.LabelStyle labelStyle = new Label.LabelStyle();
        labelStyle.font = bitmapFont;
        final Label label = new Label("SUPER SMASK ZERO", labelStyle);

        Container<Label> labelContainer = new Container<>(label);
        labelContainer.fill();
        labelContainer.setTransform(true);
        labelContainer.setWidth(label.getWidth());
        labelContainer.setHeight(label.getHeight());
        labelContainer.setOrigin(Align.center);
        Interpolation interpolation = Interpolation.sine;
        labelContainer.addAction(forever(
            sequence(
                parallel(
                    alpha(0.8f, 2f, interpolation),
                    rotateTo(2f, 2f, interpolation)
                ),
                parallel(
                    alpha(1f, 2f, interpolation),
                    rotateTo(-2f, 2f, interpolation)
                )
            )
        ));

        root.add(labelContainer).center();

        //stage.setDebugAll(true);
    }

    @Override
    public void show() {

    }

    @Override
    public void render(float delta) {
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
        stage.act(delta);
        stage.draw();
    }

    @Override
    public void resize(int width, int height) {
        stage.getViewport().update(width, height, true);
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
        stage.dispose();
    }

}
