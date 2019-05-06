#include <iostream>
#include <functional>

class World {
private:
    std::function<void(int)> collisionCallback;
public:
    void subscribeToCollisions(std::function<void(int)> callback) {
        this->collisionCallback = callback;
    }

    void call() {
        collisionCallback(10);
    }
};

class Test {
public:
    Test(World& world) {
        using namespace std::placeholders;
        world.subscribeToCollisions(std::bind(&Test::handler, this, _1));
    }

    void handler(int input) {
        std::cout << input << std::endl;
    }
};

int main(int argc, char const *argv[])
{
    World world;
    Test test(world);
    world.call();
    return 0;
}