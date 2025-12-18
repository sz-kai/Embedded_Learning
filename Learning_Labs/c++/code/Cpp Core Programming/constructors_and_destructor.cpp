/*===============================================================================================*/
/*========= 构造函数与析构函数                                                            ==========*/
/*===============================================================================================*/
#if 0

#include "iostream"
using namespace std;

/*构造函数*/
/*语法：`类名(){}`*/
/*1. 构造函数名与类名相同，无返回值，可以有形参，因此可以发生重载*/
/*2. 若不创建构造函数，编辑器也会创建一个空的构造函数*/
/*3. 构造函数在程序创建类对象时调用，且只调用一次*/

/*析构函数*/
/*语法：`~类名(){}`*/
/*1. 析构函数名与类名相同，但之前需要加~，无返回值，无形参，不可发生重载*/
/*2. 若不创建析构函数，程序也会创建一个空的析构函数*/
/*3. 析构函数在对象销毁前调用，且会调用一次*/

class Person
{
public:
    /*构造函数*/
    Person()
    {
        cout << "调用Person构造函数" << endl;
    }
    /*析构函数*/
    ~Person()
    {
        cout << "调用Person析构函数" << endl;
    }
};

void fun1()
{
    Person P1;/*会在创建P1时调用构造函数，在执行完fun1(销毁P1)时调用析构函数*/
}

int main()
{
    fun1();
    Person P2;/*在创建P2时会调用构造函数，但在“按任意键结束”前不会调用析构函数，原因在system("pause");*/
    system("pause");/*“按任意键结束”是因为这行代码导致，再未按任意键时，main还未退出，类P2不会销毁，所以不会调用析构函数*/
                    /*但会再程序结束的一瞬间调用析构函数*/
    return 0;
}
#endif

/*===============================================================================================*/
/*========= 构造函数的分类与调用方法                                                       ==========*/
/*===============================================================================================*/
#if 0

#include "iostream"
using namespace std;

/*构造函数分类*/
/*按参数*/
/*1. 有参构造*/
/*2. 无参构造*/
/*按类型*/
/*1. 普通构造*/
/*2. 拷贝构造*/

/*构造函数调用方法*/
/*括号法*/
/*显示法*/
/*隐式转换法*/

class Person
{
public:
    /*无参构造*/
    Person()
    {
        m_age = 20;
        cout << "Person的无参构造" << endl;
    }
    /*有参构造*/
    Person(int age)
    {
        m_age = age;
        cout << "Person的有参构造" << endl;
    }
    /*拷贝构造*/
    Person(const Person &p)
    {
        m_age = p.m_age;
        cout << "Person的拷贝构造" << endl;
    }
    /*析构函数*/
    ~Person()
    {
        cout << "Person的析构函数" << endl;
    }
    void read_age()
    {
        cout << "age = " << m_age << endl;
    }

private:
    int m_age;
};

int main()
{
    /*调用方法*/
    /*1. 括号法*/
    Person p1; /*调用无参构造*/
    //Person p1(); /*调用无参构造时不能带括号，否则编译器会将其当成声明*/
    p1.read_age();
    Person p2(10); /*调用有参构造*/
    p2.read_age();
    Person p3(p2); /*调用拷贝构造*/
    p3.read_age();
    
    /*2. 显式法*/
    Person p4 = Person(50);/*调用有参构造*/
    p4.read_age();
    // Person(50);/*这里创建了一个匿名对象，在执行完这行代码后就会调用析构函数，即生命周期只在此行，这点要注意
    //Person(p4);/*不能使用拷贝构造初始化匿名对象，这行编译器也会将其看成声明，Person p4，编译器会报错*/
    Person p5 = Person(p4);/*调用拷贝构造*/
    p5.read_age();

    /*3. 隐式转换法*/
    Person p6 = 80;/*调用有参构造*/
    p6.read_age();
    Person p7 = p6;/*调用拷贝构造*/
    p7.read_age();

    system("pause");
    return 0;
}
#endif

/*===============================================================================================*/
/*=========                          拷贝构造函数调用时机                              ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/*拷贝构造函数调用时机*/
/*1. 使用已创建的对象初始化一个新对象时*/
/*2. 以值传递方式将对象传递给函数时*/
/*3. 以值的形式返回一个**局部向量**时(这里应该是错的或者过时的规则，现在这种情况调用的是无参构造)*/

class Person
{
public:
    Person()
    {
        m_age = 10;
        cout << "Person的无参构造函数" << endl;
    }
    Person(int age)
    {
        m_age = age;
        cout << "Person的有参构造函数" << endl;
    }
    Person(const Person &p)
    {
        m_age = p.m_age;
        cout << "Person的拷贝构造函数" << endl;
    }
    ~Person()
    {
    }

public:
    int m_age;
};

void test1(Person p)
{
}

Person test2()
{
    Person p;
    cout << (int *)&p << endl;
    return p;
}


int main()
{

    // Person p1;/*无参构造*/
    // Person p2 = p1;/*在使用已创建的对象初始化一个新对象时,会调用拷贝构造*/
    // test1(p1);/*在使用值传递的方式给函数传参时，会调用拷贝构造*/
    Person p3 = test2();/*这里调用的是无参构造，虽然Person p3 = test2()共创建了p3和p两个局部变量，但实际上共用的一处地址，本质是一个变量*/
    cout << (int *)&p3 << endl;
    system("pause");
    return 0;
}
#endif

/*===============================================================================================*/
/*=========                               构造函数调用规则                                ==========*/
/*===============================================================================================*/
#if 0

#include "iostream"
using namespace std;

/*若不提供构造函数，编译器会提供以下几个默认构造函数*/
/* 1. 默认无参构造函数，空实现 */
/* 2. 默认拷贝构造函数，简单赋值操作 */
/* 2. 默认析构函数，空实现 */

/*当提供有参构造函数时，编译器不会再提供默认无参构造函数，但仍会提供默认拷贝构造函数*/
/*当提供拷贝构造函数时，编译器不会再提供任何其他构造函数*/
class Person
{
public:
    // Person()
    // {
    //     m_age = 10;
    //     cout << "Person的无参构造函数" << endl;
    // }
    Person(int age)
    {
        m_age = age;
        cout << "Person的有参构造函数" << endl;
    }
    Person(const Person &p)
    {
        m_age = p.m_age;
        cout << "Person的拷贝构造函数" << endl;
    }
    // ~Person()
    // {
    // }

public:
    int m_age;
};



// void test1()
// {
//     /*提供有参构造时*/
//     Person p1;/*调用默认无参构造函数*/
//     Person p2(p1);/*调用默认拷贝构造函数*/
// }

void test2()
{
    /*提供拷贝构造函数时*/
    // Person p1;/*编译器不会再提供任何构造函数，此时会报错*/
    // Person p1(10);/*编译器不会再提供任何构造函数，此时会报错*/
    Person p2 = 10;/*调用默认拷贝构造函数*/
    Person p3(p2);
    cout << p3.m_age << endl;
}

void test3()
{
    /*无任何构造函数时*/
    // Person p1;/*编译器不会再提供默认无参沟站函数，此时会报错*/
    Person p1(10);
    Person p2(p1);/*调用默认拷贝构造函数*/
    cout << p2.m_age << endl;
}

int main()
{
    //test1();
    test2();
    system("pause");
    return 0;
}
#endif

/*===============================================================================================*/
/*=========                               深拷贝与浅拷贝                                ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/*当调用构造函数对一个变量在堆中分配内存时，如果调用默认拷贝构造函数创建一个新类对象时*/
/*会造成**浅拷贝**问题*/
/*调用默认拷贝构造函数会进行简单的赋值，这时，两个类对象会指向同一个堆内存*/
/*当先调用析构函数释放其中一个类对象时，另一个对象仍指向这块内存，调用析构函数会再次释放这块堆内存，使程序崩溃*/

/* **浅拷贝**发生在**将一个指向堆内存的指针简单的赋值给另一个指针变量时**，如果重复释放这块内存，会使程序崩溃 */
/* 解决方法是进行**深拷贝**，即不进行简单的赋值操作，而是在堆上开辟一块新的内存*/

/* 如果属性有在堆区开辟的，**一定要自己提供拷贝构造函数**，防止浅拷贝带来的问题 */

class Person
{
public:
    Person(int age, int *height)
    {
        m_age = age;
        m_height = new int(*height);
        cout << "Person的有参构造函数" << endl;
    }
    Person(const Person &p)
    {
        m_age = p.m_age;
        // m_height = p.m_height;/*这样导致浅拷贝问题，使用delete重复释放一块内存*/
        m_height = new int(*p.m_height); /*这样就是深拷贝，将p指向内存的值放在一块新开辟的内存中*/
        cout << "Person的拷贝构造函数" << endl;
    }
    ~Person()
    {
        if (m_height != NULL)
        {
            delete m_height;
            m_height = NULL;
        }
    }

public:
    int m_age;
    int *m_height;
};

void test1()
{
    int h = 180;
    Person p1(10, &h);
    Person p2(p1);
}

int main()
{
    // test1();
    test1();
    system("pause");
    return 0;
}
#endif

/*===============================================================================================*/
/*=========                               初始化列表                                ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/* 初始化列表语法 */
/* 构造函数(): 属性1(值),属性2(值),属性3(值){} */

class Person
{
public:
    Person(int age, int height):m_age(age),m_height(height)
    {
        cout << "Person的有参构造函数" << endl;
    }

    void printf_person()
    {
        cout << "m_age = " << m_age << endl;
        cout << "m_height = " << m_height<< endl;
    }

public:
    int m_age;
    int m_height;
};

void test1()
{
    Person p1(10, 180);
    p1.printf_person();
}

int main()
{
    test1();
    system("pause");
    return 0;
}
#endif

/*===============================================================================================*/
/*=========                               类对象作为类成员                                ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/*当一个类对象作为类成员时，将这个类对象称为**成员对象** */

class Phone
{
public:
    Phone(string name)
    {
        m_name = name;
        cout << "Phone的构造函数" << endl;
    }
    ~Phone()
    {
        cout << "Phone的析构函数" << endl;
    }
public:
    string m_name;
};

class Person
{
public:
    Person(string name, string p_name) : m_name(name), m_p_name(p_name)
    {
        cout << "Person的构造函数" << endl;
    }
    ~Person()
    {
        cout << "Person的析构函数" << endl;
    }
    void printf_person()
    {
        cout << m_name << "的手机是" << m_p_name.m_name << endl;
    }
public:
    string m_name;
    Phone m_p_name;
};

void test1()
{
    Person p("小明", "菠萝");
    p.printf_person();
}

int main()
{
    test1();
    system("pause");
    return 0;
}
#endif

/*===============================================================================================*/
/*=========                                  静态成员变量                                   ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/* 在成员变量或成员函数前加static，就是静态成员 */

/* 静态成员变量 */
/* 1. 类内声明，类外初始化 */
/* 2. 所有类对象共用一个静态成员变量 */
/* 3. 编译时分配内存 */

/* 静态成员函数 */
/* 1. 所有类对象共用一个静态成员函数 */
/* 2. 静态成员函数只能访问静态成员变量 */

class Person
{
public:
   

public:
    static int age;

private:
    static int height;/*静态成员变量也可设置属性*/
};
/*类外初始化*/
int Person::age = 20;
int Person::height = 180;

void test1()
{
    Person p1;
    p1.age = 50;
    cout << p1.age << endl;
    Person p2;
    p1.age = 300;/*所有类对象共用一个静态成员变量*/
    cout << p1.age << endl;
    cout << p2.age << endl;
    /*通过类名访问*/
    cout << Person::age << endl;
}

int main()
{
    test1();
    system("pause");
    return 0;
}
#endif

/*===============================================================================================*/
/*=========                                  静态成员函数                                   ==========*/
/*===============================================================================================*/
#if 1
#include "iostream"
using namespace std;

/* 在成员变量或成员函数前加static，就是静态成员 */

/* 静态成员变量 */
/* 1. 类内声明，类外初始化 */
/* 2. 所有类对象共用一个静态成员变量 */
/* 3. 编译时分配内存 */

/* 静态成员函数 */
/* 1. 所有类对象共用一个静态成员函数 */
/* 2. 静态成员函数只能访问静态成员变量 */

class Person
{
public:
   static void fun()
   {
       height = 180;
       //age = 18;/*静态成员函数只能访问静态成员变量，这里会报错*/
       cout << "静态函数调用" << endl;
   }

public:
    int age;
    static int height;/*静态成员变量也可设置属性*/
};
/*类外初始化*/
int Person::height = 180;

void test1()
{
    Person p1;
    Person p2;
    p1.fun();/*静态函数类对象共有*/
    p2.fun();
    Person::fun();/*通过类名调用*/
}

int main()
{
    test1();
    system("pause");
    return 0;
}
#endif
