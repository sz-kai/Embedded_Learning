#include "iostream"
using namespace std;

/*使用new从堆中分配一个int大小内存，不同于malloc，new会返回一个具体类型的指针，而不是void* */
int* fun1()
{
    /*这里返回的虽然是一个局部变量指针，但因为是从堆中分配，退出函数后这块内存不会被销毁*/
    return new int;
}

/*使用new操作符分配一个int类型内存,并初始化为10 */
int* fun2()
{
    /*分配一个int类型内存，赋值为10*/
    return new int(10);
}

/*使用new分配一个类对象内存，在分配内存时会调用这个类的构造函数初始化这块内存*/
// my_class* fun3()
// {
//     return new my_clash();
// }

/*使用new分配一个数组*/


int* fun4()
{
    return new int[10];
}


int main()
{
    int *p1 = fun1();
    *p1 = 20;
    cout << "p1指向的值为:" << *p1 << endl;
    delete p1;

    int *p2 = fun2();
    cout << "p2指向的值为:" << *p2 << endl;
    delete p2;

    // my_clash *p3 = fun3();
    // delete p3;

    int *p4 = fun4();
    cout << "p4指向的数组为:";
    for (int i = 0; i < 10;i++)
    {
        p4[i] = i;
        cout << p4[i] << " ";
    }
    cout << endl;
    system("pause");
    return 0;
}