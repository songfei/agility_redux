# agility_redux

Agility Redux 是一款模块化，可插拔的 Redux 状态管理库。

* 支持多业务模块，模块间解耦。
*  模块可插拔。
*  State 、 Action 区分 Public 和 Private，私有部分仅能在模块内部访问和使用。
*  State 多份实例，可以 Push 和 Pop。

本项目包含以下几个独立部分，可分别使用，也可以组合使用：

*  `agility_redux`  基本 redux 实现，纯 Dart 库不依赖 Flutter， 方便单元测试
*  `agility_redux_widget `  redux 相关的 widget 
*  `agility_redux_bloc ` 业务模块管理，路由管理。 


## 特别说明

Thanks for redbrogdon, inspired by the [rebloc](https://github.com/redbrogdon/rebloc) project.