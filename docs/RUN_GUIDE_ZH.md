# 中文运行说明

## 最简单的运行方法

1. 将 MATLAB 当前文件夹切换到本项目根目录，即能直接看到 `START_HERE.m` 的目录。
2. 在命令窗口输入：

```matlab
START_HERE
```

不要进入 `scripts` 文件夹运行，也不需要手动修改路径。

## 正常输出

命令窗口会显示：

- 输入数据检查结果
- 收敛迭代次数
- 最终最大功率不平衡量
- 系统总有功、无功损耗
- 各节点电压、相角和计算得到的发电功率

同时弹出四联图并生成：

```text
results/power_flow_results.xlsx
results/power_flow_dashboard.png
reports/power_flow_report.html
```

## Excel 输入说明

- `Settings`：基准容量、误差阈值、最大迭代次数、电压告警上下限
- `Buses`：节点类型、负荷、发电、初始电压和并联导纳
- `Branches`：线路参数、变压器变比、相移和投运状态

节点类型只能写：`Slack`、`PV` 或 `PQ`。
