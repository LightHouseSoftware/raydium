module raydium.component.container;

import raydium.component;

import std.typecons;
import std.string;

enum ContainerState : string
{
    NORMAL = "normal",
    FOCUS = "focus",
    ACTIVE = "active",
    CHECKED = "checked",
    DISABLED = "disabled"
}

interface IContainer
{
    string id() @property const;

    void styleId(string);
    string styleId();
    ContainerState state() @property const;
    T property(T)(string name);
    void state(ContainerState value) @property;
    void dirty(bool value);
    void update();
    void measure(Rectangle rect);
    void arrange();
    void draw();
    void render();
}

abstract class Container : IContainer
{
    protected
    {
        string _id;
        bool _dirty;
        string _styleId;
        Rectangle _rect;
        ContainerState _state;
    }

    this(string id = null, string styleId = null)
    {
        _id = id;
        _styleId = styleId;
        if(_styleId is null) _styleId = "container";
        _state = ContainerState.NORMAL;
        _dirty = true;
    }

    string id() @property const
    {
        return _id;
    }

    void styleId(string id)
    {
        if(_styleId != id)
        {
            _styleId = id;
            _dirty = true;
        }
    }

    string styleId()
    {
        return _styleId;
    }

    ContainerState state() @property const
    {
        return _state;
    }

    void state(ContainerState value) @property
    {
        if(_state != value)
        {
            _state = value;
        }
    }

    void dirty(bool value) @property
    {
        _dirty = value;
    }

    override bool opEquals(Object o) const
    {
        if (auto other = cast(Container) o)
            return id == other.id;
        return false;
    }

    abstract void measure(Rectangle rect);
    abstract void arrange();
    abstract void update();
    abstract void draw();

    void render()
    {
        if (_dirty)
            arrange();

        auto visible = property!bool(StyleProperty.visible);
        auto opacity = property!float(StyleProperty.opacity);
        auto display = property!bool(StyleProperty.display);

        if ((!visible.isNull && !visible.get) || (!opacity.isNull && opacity.get == 0) || (!display.isNull && !display.get))
            return;

        BeginScissorMode(cast(int) _rect.x, cast(int) _rect.y, cast(int) _rect.width, cast(int) _rect.height);

        // Рендерим фон
        drawBackground();

        // Рендерим рамку поверх фона
        drawBorder();

        // Рендерим контент
        draw();

        EndScissorMode();

        update();
    }

    protected Nullable!T property(T)(string name)
    {
        Nullable!T prop;
        
        if(_state != ContainerState.NORMAL)
        {
            prop = JSL.stateProperty!T(styleId(), state(), name);
        }
        
        if(prop.isNull)
        {
            prop = JSL.property!T(styleId, name);
        }

        return prop;
    }

    protected Rectangle marginBox()
    {
        return _rect;
    }

    protected Rectangle borderBox()
    {
        auto margin = property!Dimensions(StyleProperty.margin);
        if(margin.isNull)
        {
            return _rect;
        }

        return calculateBox(_rect, margin.get);
    }

    protected Rectangle paddingBox()
    {
        auto border = property!Border(StyleProperty.border);
        if (border.isNull)
        {
            return borderBox;
        }

        return calculateBox(borderBox, Dimensions(border.get.width));
    }

    protected Rectangle contentBox()
    {
        auto padding = property!Dimensions(StyleProperty.padding);
        if (padding.isNull)
        {
            return paddingBox;
        }

        return calculateBox(paddingBox, padding.get);
    }

    protected Rectangle calculateBox(Rectangle rect, Dimensions prop)
    {
        Rectangle box;

        //TODO: тоже везде рассчет относительно родителя

        box.x = rect.x + prop.left.toPixels(_rect.width);
        box.y = rect.y + prop.top.toPixels(_rect.height);
        box.width = rect.width - prop.left.toPixels(_rect.width) - prop.right.toPixels(_rect.width);
        box.height = rect.height - prop.top.toPixels(_rect.height) - prop.bottom.toPixels(_rect.height);

        return box;
    }

    protected void drawBackground()
    {
        //TODO: нужно сделать предзагрузку в кеш всех свойств темы и всех текстур, шейдеров, шрифтов и т.д.

        Nullable!string backImage = property!string(StyleProperty.backgroundImage);

        Nullable!BorderRadius borderRadius = property!BorderRadius(StyleProperty.borderRadius);

        if(!backImage.isNull)
        {
            //TODO: вынести инициализацию текстур в загрузчик темы
            if(!ResourceCache.isTexture(backImage.get.toLower))
            {
                auto res = ResourceManager.resource(backImage.get.toLower); //TODO: сделать, чтобы в свойстве сразу было в нужном регистре
                Image image = LoadImageFromMemory(res.ext.ptr, res.data.ptr, cast(int) res.data.length);
                Texture2D texture = LoadTextureFromImage(image);
                ResourceCache.texture(backImage.get.toLower, texture);
                UnloadImage(image);
            }

            auto texture = ResourceCache.texture(backImage.get.toLower).get;

            if(borderRadius.isNull || borderRadius.get.empty)
            {
                // отрисовка тестуры фона с рескалингом в нужный прямоугольник
                DrawTexturePro(texture, Rectangle(0, 0, texture.width, texture.height), paddingBox, Vector2(0, 0), 0.0f, Colors.WHITE);
            }
            else
            {
                // if(!ResourceCache.isShader("borderRadius"))
                // {
                //     string fs = q{
                //         #version 330 core

                //         in vec2 fragTexCoord;
                //         uniform sampler2D texture0;
                //         uniform vec2 textureSize;
                //         uniform float borderRadius;

                //         out vec4 finalColor;

                //         void main() {
                //             // Texel color fetching from texture sampler
                //             vec4 texelColor = texture(texture0, fragTexCoord);

                //             // Calculate the pixel position within the texture
                //             vec2 pos = fragTexCoord * textureSize;

                //             // Calculate the distance from the edges
                //             vec2 distFromEdge = min(pos, textureSize - pos);

                //             // Check if we're within the border radius of a corner
                //             bool withinBorderRadius = distFromEdge.x < borderRadius && distFromEdge.y < borderRadius;

                //             // Calculate which corner we're in
                //             vec2 cornerDist;
                //             if (pos.x < borderRadius) {
                //                 // Left side
                //                 if (pos.y < borderRadius) {
                //                     // Bottom left corner
                //                     cornerDist = vec2(borderRadius) - distFromEdge;
                //                 } else if (pos.y > textureSize.y - borderRadius) {
                //                     // Top left corner
                //                     cornerDist = pos - vec2(borderRadius, textureSize.y - borderRadius);
                //                 }
                //             } else if (pos.x > textureSize.x - borderRadius) {
                //                 // Right side
                //                 if (pos.y < borderRadius) {
                //                     // Bottom right corner
                //                     cornerDist = pos - vec2(textureSize.x - borderRadius, borderRadius);
                //                 } else if (pos.y > textureSize.y - borderRadius) {
                //                     // Top right corner
                //                     cornerDist = textureSize - pos - vec2(borderRadius);
                //                 }
                //             }

                //             // If we're within the border radius, calculate if we're inside the rounded corner
                //             if (withinBorderRadius && length(cornerDist) > borderRadius) {
                //                 finalColor = vec4(texelColor.rgb, 0.0); // Make pixel transparent
                //             } else {
                //                 finalColor = texelColor; // Keep original pixel
                //             }
                //         }
                //     };

                //     auto shader = LoadShaderFromMemory(null, fs.ptr);

                //     auto br = cast(float)borderRadius.get.topLeft.toPixels(paddingBox.width);
                //     //float[2] txSize = [texture.width, texture.height];
                //     Vector2 txSize = {paddingBox.width, paddingBox.height};

                //     SetShaderValue(shader, GetShaderLocation(shader, "borderRadius"), &br, SHADER_UNIFORM_FLOAT);
                //     SetShaderValue(shader, GetShaderLocation(shader, "textureSize"), &txSize, SHADER_UNIFORM_VEC2);

                //     ResourceCache.shader("borderRadius", shader);
                // }

                //auto shader = ResourceCache.shader("borderRadius").get;

                //BeginBlendMode(BLEND_ALPHA);
                //BeginShaderMode(shader);

                //TODO: сделать материал и меш, и отрендерить меш вместо рендера текстуры

                //DrawTexturePro(texture, Rectangle(0, 0, texture.width, texture.height), paddingBox, Vector2(0, 0), 0.0f, Colors.WHITE);

                //EndShaderMode();
                //EndBlendMode();
            }

            return;
        }

        Nullable!Gradient backGradient = property!Gradient(StyleProperty.backgroundGradient);
        if(!backGradient.isNull)
        {
            Gradient gradient = backGradient.get;
            if(gradient.type == GradientType.LINEAR)
            {
                if(gradient.isVertical)
                {
                    DrawRectangleGradientV(cast(int)paddingBox.x, cast(int)paddingBox.y, cast(int)paddingBox.width, cast(
                            int)paddingBox.height + 1, gradient.colors[0], gradient.colors[1]);
                }
                else 
                {
                    DrawRectangleGradientH(cast(int)paddingBox.x, cast(int)paddingBox.y, cast(int)paddingBox.width, cast(
                            int)paddingBox.height + 1, gradient.colors[0], gradient.colors[1]);
                }
            }
            else if(gradient.type == GradientType.RADIAL)
            {
                DrawCircleGradient(cast(int)(paddingBox.width/2), cast(int)(paddingBox.height/2), 
                    cast(int)(max(paddingBox.width, paddingBox.height)/2), 
                    gradient.colors[0], gradient.colors[1]
                );
            }

            return;
        }

        Nullable!Color backColor = property!Color(StyleProperty.backgroundColor);
        if(!backColor.isNull)
        {
            if(borderRadius.isNull || borderRadius.get.empty)
            {
                DrawRectangleRec(paddingBox, backColor.get);
            }
            else 
            {
                DrawRectangleRounded(paddingBox, borderRadius.get.topLeft.toPixels(_rect.height), 8, Colors.TRANSPARENT);
            }

            return;
        }
    }

    protected void drawBorder()
    {
        auto border = property!Border("border");
        auto borderRadius = property!BorderRadius("border-radius");

        if (border.isNull || border.get.empty)
            return;

        if (borderRadius.isNull || borderRadius.get.empty)
        {
            DrawRectangleLinesEx(borderBox, border.get.width.toPixels(_rect.height), border.get.color);
        }
        else
        {
            float width = border.get.width.toPixels(_rect.width);

            Rectangle bbox = Rectangle(
                        borderBox.x + width, 
                        borderBox.y + width,
                        borderBox.width - width * 2,
                        borderBox.height - width * 2
            );

            DrawRectangleRoundedLines(bbox, borderRadius.get.topLeft.toPixels(_rect.height), 8, border.get.width.toPixels(
                    _rect.height), border.get.color);
        }
    }
}