module raydium.core.units;

import std.typecons;

import raydium.core;

SizeValue percent(float value)
{
    return SizeValue(value, SizeUnit.Percentage);
}

BoxSpacing percent(Vector4 value)
{
    return BoxSpacing(value.x.percent, value.y.percent, value.z.percent, value.w.percent);
}

BoxSpacing percent(Vector3 value)
{
    return BoxSpacing(value.x.percent, value.y.percent, value.z.percent);
}

BoxSpacing percent(Vector2 value)
{
    return BoxSpacing(value.x.percent, value.y.percent);
}

SizeValue px(float value)
{
    return SizeValue(value, SizeUnit.Pixels);
}

BoxSpacing px(Vector4 value)
{
    return BoxSpacing(value.x.px, value.y.px, value.z.px, value.w.px);
}

BoxSpacing px(Vector3 value)
{
    return BoxSpacing(value.x.px, value.y.px, value.z.px);
}

BoxSpacing px(Vector2 value)
{
    return BoxSpacing(value.x.px, value.y.px);
}