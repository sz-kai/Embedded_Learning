/*===============================================================================================*/
/*=========                               继承基本语法                                   ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/* 继承基本语法为: */
/* class 子类 : 权限 父类 */

/* 当对象之间存在共性, 运用继承可以较少代码量 */

/* 当打印网页时, 不同网页可能拥有同样的头部,底部,侧边栏. 只有中间内容有差距*/
/* 当不使用继承实现多个网页时 */
class Cpp
{
public:
    void header()
    {
        cout << "首页, 公开课, 登录, 注册... (公共头部)" << endl;
    }
    void bottom()
    {
        cout << "帮助中心, 交流合作, 站内地图... (公共底部)" << endl;
    }
    void list()
    {
        cout << "Java, Python, C++ ...(公共分类列表)" << endl;
    }
    void content()
    {
        cout << "C++ 具体内容" << endl;
    }
};

class Python
{
public:
    void header()
    {
        cout << "首页, 公开课, 登录, 注册... (公共头部)" << endl;
    }
    void bottom()
    {
        cout << "帮助中心, 交流合作, 站内地图... (公共底部)" << endl;
    }
    void list()
    {
        cout << "Java, Python, C++ ...(公共分类列表)" << endl;
    }
    void content()
    {
        cout << "Python 具体内容" << endl;
    }
};

class Java
{
public:
    void header()
    {
        cout << "首页, 公开课, 登录, 注册... (公共头部)" << endl;
    }
    void bottom()
    {
        cout << "帮助中心, 交流合作, 站内地图... (公共底部)" << endl;
    }
    void list()
    {
        cout << "Java, Python, C++ ...(公共分类列表)" << endl;
    }
    void content()
    {
        cout << "Java 具体内容" << endl;
    }
};

void view_webpage()
{
    cout << "================C++ webpage==============" << endl;
    Cpp cpp;
    cpp.header();
    cpp.list();
    cpp.content();
    cpp.bottom();
    cout << "================Python webpage==============" << endl;
    Python python;
    python.header();
    python.list();
    python.content();
    python.bottom();
    cout << "================Java webpage==============" << endl;
    Java java;
    java.header();
    java.list();
    java.content();
    java.bottom();
}

/*继承实现方式*/
class Basic_webpage
{
public:
    void header()
    {
        cout << "首页, 公开课, 登录, 注册... (公共头部)" << endl;
    }
    void bottom()
    {
        cout << "帮助中心, 交流合作, 站内地图... (公共底部)" << endl;
    }
    void list()
    {
        cout << "Java, Python, C++ ...(公共分类列表)" << endl;
    }
};

/*继承*/
class Cpp_inherit : public Basic_webpage
{
public:
    void content()
    {
        cout << "Java 具体内容" << endl;
    }
};

class Python_inherit : public Basic_webpage
{
public:
    void content()
    {
        cout << "Python 具体内容" << endl;
    }
};

class Java_inherit : public Basic_webpage
{
public:
    void content()
    {
        cout << "Java 具体内容" << endl;
    }
};

void view_webpage_inherit()
{
    cout << "================C++ webpage==============" << endl;
    Cpp_inherit cpp;
    cpp.header();
    cpp.list();
    cpp.content();
    cpp.bottom();
    cout << "================Python webpage==============" << endl;
    Python_inherit python;
    python.header();
    python.list();
    python.content();
    python.bottom();
    cout << "================Java webpage==============" << endl;
    Java_inherit java;
    java.header();
    java.list();
    java.content();
    java.bottom();
}

int main()
{
    // view_webpage();
    view_webpage_inherit();
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*=========                               继承方式                                      ==========*/
/*===============================================================================================*/
#if 1
#include "iostream"
using namespace std;

/* 1. public继承 */
/* 父类中的public, protected成员, public方式继承后, 仍是public, protected属性 */
/* 父类中的private成员, public方式继承后, 类内类外都不能访问 */

/* 2. protected继承 */
/* 父类中的public, protected成员, public方式继承后, 均变为protected属性, 类内可访问, 类外不可 */
/* 父类中的private成员, protected方式继承后, 类内类外都不能访问 */

/* 3. private继承 */
/* 父类中的public, protected成员, private方式继承后,  类内可访问, 类外不可 */
/* 父类中的private成员, private方式继承后, 类内类外都不能访问 */

class Base
{
public:
    int m_a;

protected:
    int m_b;

private:
    int m_c;
};

class Subclass1 : public Base
{
    void fun()
    {
        m_a = 10;
        m_b = 10;
        //m_c = 10;/*private public继承后不能访问*/
    }
};

void test1()
{
    Subclass1 s1;
    s1.m_a = 20;/*类外只能访问公共权限成员*/
}

class Subclass2 : protected Base
{
    void fun()
    {
        m_a = 10;/*public protected继承后不能访问*/
        m_b = 10;/*protected protected继承后不能访问*/
        //m_c = 10;/*private public继承后不能访问*/
    }
};

void test2()
{
    Subclass2 s1;
    //s2.m_a = 20;/*protected继承方式下, 所有成员都不能访问*/
}

class Subclass3 : private Base
{
    void fun()
    {
        m_a = 10;
        m_b = 10;
        //m_c = 10;/*private public继承后不能访问*/
    }
};

void test3()
{
    Subclass3 s1;
    //s2.m_a = 20;/*所有成员都不能访问*/
}

int main()
{
    system("pause");
    return 0;
}

#endif
