module raydium.core.math;

import raydium.core;
import std.algorithm;

Rectangle add(Rectangle a, Rectangle b)
{
    auto x = min(a.x, b.x);
    auto y = min(a.y, b.y);

    auto width = max(a.x + a.width, b.x + b.width) - x;
    auto height = max(a.y + a.height, b.y + b.height) - y;

    return Rectangle(x, y, width, height);
}

Rectangle subtract(Rectangle a, Rectangle b)
{
    auto x = a.x - b.x;
    auto y = a.y - b.y;
    auto width = a.width - b.width;
    auto height = a.height - b.height;

    return Rectangle(x, y, width, height);
}

Rectangle multiply(Rectangle a, float value)
{
    return Rectangle(a.x * value, a.y * value, a.width * value, a.height * value);
}

Rectangle divide(Rectangle a, float value)
{
    return Rectangle(a.x / value, a.y / value, a.width / value, a.height / value);
}

bool intersect(Rectangle a, Rectangle b)
{
    return (a.y < b.x + b.width) &&
        (a.y + a.width > b.x) &&
        (a.x < b.y + b.height) &&
        (a.x + a.height > b.y);
}

bool intersect(Vector2 a, Rectangle b)
{
    return (a.x >= b.x && a.x <= b.width) && (a.y >= b.y && a.y <= b.height);
}

bool equals(Rectangle a, Rectangle b)
{
    return (a.x == b.x && a.y == b.y && a.width == b.width && a.height == b.height);
}