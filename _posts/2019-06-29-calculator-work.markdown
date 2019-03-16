---
title: "My work on the Windows Calculator"
layout: post
---

Recently Microsoft released the [Windows Calculator][calculator] as open source
and it has been a huge trip down memory line for me. You see, I was on the team
that created the Windows 8 version of the Calcutor, which is the direct ancestor
of the code that was released.

Much of the code remains the same compared to the Windows 8 version. The new
version has changes realted to the new features added in Windows 10 to allow UWP
apps to run in windows instead of only in the full screen mode that Windows 8
introduced.

The most remarkable thing to say about this codebase is that is was written in
[`C++/CX`][cppcx], a variant of C++ that Microsoft created during the Windows 8
timeframe to more _easily_ combine the WinRT types with C++ code. In a way it
was Microsoft response to Objectie-C++.

The `C++/CX` language had things like using the `^` symbol to signify a smart
pointer to a WinRT instance, like so:
```c++
Window^ myWindow = new Window();
myWindow->method();
```

WinRT is built on top of COM so the liftime of objects is managed by using ref
counting. You call `AddRef()` when you want a new reference and `Release()` when
you are done with it. The `^` symbol allowed the compiler to do this for you in
a very effective way.

The compiler would have special handling for the `^` symbol so it would avoid
calling the `AddRef()` method when passing instances and do other optimizations
in an effort to generate effective code. This was in following with the C++
mantra of being as effective as possible. By annotating the WinRT types with the
`^` symbol you also got to follow the _pay for play_ principle. Regular C++ code
was not affected by the WinRT integrations.

The counterpart of the `^` was the `%` symbol, which allowed you to take
_reference_ to a WinRT type. I don't remember using this much however.

All of the UI work was done based on the Windows XAML framework, on which I also
worked before moving on to producing apps. The Windows XAML framework was based
on WPF, inheriting a lot of the same features and idiosyncrasies.

One of the most difficult areas of WPF to port to Windows XAML is the data
binding system. This system allows you to specify that one property in a UI
element is based on the value of a corresponding value in the model. The binding
system will also track changes in the model property and update the UI property.

The binding system in WPF was written in .NET and therefore took full advantage
of the reflection system. This meant that it could inspect objects at runtime
and determine what properties were available and read/write the values of these
properties.

The Windows XAML framework on the other hand had to work not only with .NET but
also with C++ objects. This meant that there had to be a bit of reflection being
implemented. This is why you see all of the models in the Calculator app using
the `[Windows::UI::Xaml::Data::Bindable]` attribute. This attribute informs the
C++/CX compiler that it needs to generate the information for this class.

You could also implement the `ICustomPropertyProvider` if you wanted to take
full control of this mechanism, but it was generally not necessary. The compiler
generated a really good implementation for it.

The fact that we were targetting WinRT and that we were using `C++/CX` meant
that the code was very verbose. We didn't have much of the niceties that .NET,
and C#, would give you. Working directly in `C++/CX` meant that you needed to
deal with things like `Box<T>`, different kinds of string types and so on.

One area where all of these issues get together to produce very verbose code is
in the value converters. A value converter is a class that implements the
`IValueConverter` interface. These classes are used to convert data types when
the data is moved between the model and the UI in a data binding operation.

Take the [`BooleanToVisibilityConverter`][booleanvisconv] for example. All that
this rather convoluted piece of code is doing is converting a `bool` value to a
visibility value. If the incoming value is `true` then the result will be
`Windows::UI::Xaml::Visibility::Visible` and it will be
`Windows::UI::Xaml::Visibility::Collapsed` if the incoming value is `false`.

In order the accomplish this however the code needs to take into account the
fact that what it is getting as an argument is really an `Object`
instance. Because in WinRT, as in .NET, boolean values are _value types_, this
means that the boolean value is being _boxed_ into a `Box<bool>` instance. The
code first checks for this to make sure that what is getting as an input is in
fact a boolean value, that is the following line:
```c++
auto boxedBool = dynamic_cast<Box<bool>^>(value);
```

In C# this code would be must more direct. C# also deals with boxed values, but
it has direct support to extract values. The equivalent line of code would be:
```c#
bool? boxedBool = value as bool;
```

You can use the nullable bool value here to get directly at the boolean value,
instead of getting to the box. In C# the box instance is never seen, you either
see the `Object` or you see the contents of the box.

After that the code is pretty straight forward. It gets the value out of the
`Box<bool>` instance, if that is what it was, and uses the bool value to choose
between the two visiblity values that it outputs.

One thing to note about the `(void) varName;` lines is that they were necessary
because in `C++/CX` you must specify the argument name, and it must match the
name in the WinRT interface that you are implementing. This is a requirement
inherited from the .NET roots of the WinRT type system. But synce these
parameters are unused this was producing a compiler warning. As the end goal was
to compile with the warnings as errors this is what you do to tell the compiler
that the variable has no use.

[calculator]: https://github.com/Microsoft/calculator
[cppcx]: https://en.wikipedia.org/wiki/C%2B%2B/CX
[booleanvisconv]: https://github.com/Microsoft/calculator/blob/1113ff4b8673b1dc59d8da91ae3189905b9199d9/src/Calculator/Converters/BooleanToVisibilityConverter.cpp
