

/*===============================================================================================*/
/*=========                        设计一个圆类，计算其周长                              ==========*/
/*===============================================================================================*/
#if 0

#include "iostream"
using namespace std;

#define PI 3.141593f

/**
 * @brief 定义一个圆类，计算其周长
 *
 */
class circle
{
public:
    /*成员变量*/
    float m_r; /*半径*/

    /*成员函数*/
    float calculate_perimeter()
    {
        return 2 * PI * m_r;
    }
};

int main()
{
    /*定义对象*/
    circle c1;
    c1.m_r = 1.0f;
    cout << "c1的周长 = " << c1.calculate_perimeter() << endl;
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*========= 设计一个学生类，属性有姓名与学号，可以给姓名和学号赋值，可以显示学生的姓名和学号  ==========*/
/*===============================================================================================*/
#if 0

#include "iostream"
#include "string"

using namespace std;

/**
 * @brief 学生类
 *
 */
class Student
{
public:
    string m_name;
    string m_ID;

    void set_name_ID(string name,string ID);
    void show_name_ID();
};

/**
 * @brief 设置对象姓名、ID
 * 
 */
void Student::set_name_ID(string name,string ID)
{
    m_name = name;
    m_ID = ID;
}

/**
 * @brief 显示对象姓名、ID
 * 
 */
void Student::show_name_ID()
{
    cout << "name:" << m_name << endl;
    cout << "ID:" << m_ID << endl;
}

int main()
{
    Student s1;
    s1.set_name_ID("张三", "123456");
    s1.show_name_ID();
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*=========                              类的访问权限                                   ==========*/
/*===============================================================================================*/
#if 0

#include "iostream"

using namespace std;

/**
 * @brief 人类
 *
 */
class Person
{
public:
    /*公共权限，类内、类外都可以访问*/
    string m_name;

protected:
    /*保护权限，类内可访问，类外不可访问*/
    string m_car;

private:
    /*私有权限，类内可访问，类外不可访问*/
    string m_password;

public:
    void sed_Person(string name, string car, string password);
};

void Person::sed_Person(string name, string car, string password)
{
    m_name = name;
    m_car = car;
    m_password = password;
}

int main()
{
    Person p1;
    p1.sed_Person("张三", "雅迪", "123456");
    /*下面两个类外访问不到，编译器会报错*/
    // p1.m_car;
    // p1_m_password;
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*=========                         struct与class的区别                                 ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"

using namespace std;

/*struct的成员默认访问权限是public*/
/*class的成员默认访问权限是private*/

class C1
{
    int m1;/*默认访问权限-private*/
};

struct S1
{
    int m1;/*默认访问权限-public*/
};

int main()
{
    C1 c1;
    S1 s1;
    //c1.m1;/*m1为私有权限，类外不可访问*/
    s1.m1;
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*========= 成员属性设置为私有                                                           ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"

using namespace std;

/*将成员变量设置为private优点*/
/*1. 可以自己控制读写权限*/
/*2. 对于写权限，可以检测数据有效性*/

class Person
{
public:
    /*为姓名提供读写函数*/
    void set_name(string name);
    string read_name();
    /*年龄提供读写函数，并判断输入年龄的合理性*/
    void set_age(int age);
    int read_age();
    /*密码只提供写函数，外部不可读取*/
    void set_password(string password);

private:
    string m_name;
    int m_age;
    string m_password;
};

/*为姓名提供读写函数*/
void Person::set_name(string name)
{
    m_name = name;
}
string Person::read_name()
{
    return m_name;
}
/*年龄提供读写函数，并判断输入年龄的合理性*/
void Person::set_age(int age)
{
    if(age<0||age>150)
    {
        cout << "年龄输入不合理" << endl;
        return;
    }
    m_age = age;
}
int Person::read_age()
{
    return m_age;
}
/*密码只提供写函数，外部不可读取*/
void Person::set_password(string password)
{
    m_password = password;
}

int main()
{
    Person p1;
    /*通过提供的接口读写姓名*/
    p1.set_name("张三");
    string p1_name = p1.read_name();
    cout << p1_name << endl;

    /*通过提供的接口读写年龄*/
    p1.set_age(1500);
    int p1_age = p1.read_age();
    cout << p1_age << endl;
    p1.set_age(110);
    p1_age = p1.read_age();
    cout << p1_age << endl;

    /*通过提供的接口写密码*/
    p1.set_password("123456");/*外部无法读取密码*/

    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*========= 设置一个立方体类                                                           ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"

using namespace std;

// 设计立方体类(Cube)
// 求出立方体的面积和体积
// 分别用全局函数和成员函数判断两个立方体是否相等。

class Cube
{
public:
    void set_cube(int l,int w,int h)
    {
        m_length = l;
        m_width = w;
        m_height = h;
    }
    int calculate_area()
    {
        return 2 * (m_height * m_length + m_height * m_width + m_length * m_width);
    }
    int calculate_volume()
    {
        return m_height * m_length * m_width;
    }
    void is_equal(Cube c1)
    {
        if (m_height == c1.m_height && m_length == c1.m_length && m_width == c1.m_width)
        {
            cout << "两个立方体相等" << endl;
        }
        else
        {
            cout << "两个立方体不相等" << endl;
        }
    }

private:
    int m_length;
    int m_width;
    int m_height;
};

int main()
{
    Cube C1;
    Cube C2;
    C1.set_cube(10, 20, 30);
    C2.set_cube(10, 20, 40);
    int C1_area = C1.calculate_area();
    cout << "C1面积 = " << C1_area << endl;
    int C1_volume = C1.calculate_volume();
    cout << "C1体积 = " << C1_volume << endl;
    C1.is_equal(C2);
    system("pause");
    return 0;
}

#endif


/*===============================================================================================*/
/*========= 设置一个立方体类                                                           ==========*/
/*===============================================================================================*/
#if 1
#include "iostream"

using namespace std;

// 设计立方体类(Cube)
// 求出立方体的面积和体积
// 分别用全局函数和成员函数判断两个立方体是否相等。

class Cube
{
public:
    void set_cube(int l,int w,int h)
    {
        m_length = l;
        m_width = w;
        m_height = h;
    }
    int calculate_area()
    {
        return 2 * (m_height * m_length + m_height * m_width + m_length * m_width);
    }
    int calculate_volume()
    {
        return m_height * m_length * m_width;
    }
    void is_equal(Cube c1)
    {
        if (m_height == c1.m_height && m_length == c1.m_length && m_width == c1.m_width)
        {
            cout << "两个立方体相等" << endl;
        }
        else
        {
            cout << "两个立方体不相等" << endl;
        }
    }

private:
    int m_length;
    int m_width;
    int m_height;
};

int main()
{
    Cube C1;
    Cube C2;
    C1.set_cube(10, 20, 30);
    C2.set_cube(10, 20, 40);
    int C1_area = C1.calculate_area();
    cout << "C1面积 = " << C1_area << endl;
    int C1_volume = C1.calculate_volume();
    cout << "C1体积 = " << C1_volume << endl;
    C1.is_equal(C2);
    system("pause");
    return 0;
}

#endif