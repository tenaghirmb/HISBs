import matplotlib.pyplot as plt
import numpy as np
import os
import re
from pylab import mpl

txt_path = 'scatter/'
img_path = 'scatter_plots'


mpl.rcParams['font.sans-serif'] = ['FangSong']  # 指定默认字体
mpl.rcParams['axes.unicode_minus'] = False  # 解决保存图像是负号'-'显示为方块的问题


def mk_scatter(num, dv, **kwargs):
    x, y = zip(*kwargs.values())
    plt.figure(figsize=(6, 6))
    plt.scatter(x, y)
    plt.vlines(0.5, 0, 1, colors="gray", linestyles="-", linewidth=0.3)
    plt.hlines(0.5, 0, 1, colors="gray", linestyles="-", linewidth=0.3)
    plt.plot(np.linspace(0, 1, 50), np.linspace(0, 1, 50), linewidth=0.5)
    for name, coordinate in kwargs.items():
        plt.annotate(name, coordinate, textcoords="offset points",
                     xytext=(0, -15), ha='center')
    # 设置坐标轴范围
    plt.xlim(0, 1)
    plt.ylim(0, 1)

    # 设置坐标轴刻度
    xy_ticks = np.arange(0, 1.5, 0.5)
    plt.xticks(xy_ticks)
    plt.yticks(xy_ticks)

    plt.savefig(f'{img_path}/{dv}-{num}.png', dpi=300)


def points2dict(plist):
    pdict = dict()
    for point in plist:
        matchObj = re.match('(\S*) (\S*)', point)
        website = matchObj.group(1)
        coordinate = matchObj.group(2)
        pdict[website] = eval(coordinate)
    return pdict


def parse_txt(filename):
    try:
        with open(txt_path + filename, encoding='gbk') as f:
            num = 1
            for line in f:
                info = line.split(':')[-1]
                points = info.strip().split(', ')
                pdict = points2dict(points)
                mk_scatter(num, filename.strip('.txt'), **pdict)
                num += 1
    except IsADirectoryError:
        pass


def main():
    files = os.listdir(txt_path)

    for file in files:
        parse_txt(file)


if __name__ == '__main__':
    main()
