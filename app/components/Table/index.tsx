/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable react-native/no-inline-styles */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-explicit-any */
/**
 * @description Table
*/
import { ScreenWidth } from '@/utils';
import type { SwipeoutButtonProps } from '@ant-design/react-native';
import { SwipeAction } from '@ant-design/react-native';
import React, { isValidElement, useEffect } from 'react';
import type { DimensionValue, GestureResponderEvent, LayoutChangeEvent, NativeScrollEvent, NativeSyntheticEvent, ViewStyle } from 'react-native';
import { Image, Pressable, StyleSheet, Text, View } from 'react-native';
import type { Swipeable } from 'react-native-gesture-handler';
import { ScrollView } from 'react-native-gesture-handler';
import SortImg from '@/asserts/board/sort.png';
import SortHightImg from '@/asserts/board/sort_hight.png';
import { Columns, Datas } from './mockData';
import LinearGradient from 'react-native-linear-gradient';

export interface TableColumn {
  title: string;
  dataIndex?: string;
  key: string;
  width?: number | string;
  sorter?: boolean;
  align?: 'left' | 'center' | 'right' | undefined;
  render?: (data: any, row: number, col: number) => string | React.ReactNode;
  renderHeader?: (data: TableColumn) => React.ReactNode;
}

export interface TableProps {
  columns: TableColumn[];
  data: any[];
  rowHeight?: number;
  headerHeight?: number;
  onRowClick?: (data: any, row: number) => void;
  leftSwipe?: (data: any, row: number) => SwipeoutButtonProps[];
  onSwipeAction?: (data: any, row: number) => void;
  swipeText?: string;
  isSwipeSupport?: boolean;
  style?: ViewStyle;
  // 表格左右间距
  space?: number;
  // 最大列数限制，超出最大值将按照该值计算cell宽度。TableColumn中的width优先级高于该值
  maxColumns?: number;
  // 暂不支持
  maxTableHeight?: number;
  onLayout?: (event: LayoutChangeEvent) => void;
}

type SortType = 1 | 0 | -1;

const defaultProps: TableProps = {
  columns: Columns,
  data: Datas,
  isSwipeSupport: false,
  swipeText: '查看详情',
  rowHeight: 50,
  headerHeight: 40,
  space: 20,
  // 可视范围最大列数
  maxColumns: 6,
};

const minRowWidth = 50;

const Log = (message?: any, ...optionalParams: any[]) => {
  // console.log('Table:', message, ...optionalParams);
};

const Table = (p: Partial<TableProps>) => {

  const props = { ...defaultProps, ...p };

  const [offsetX, setOffsetX] = React.useState(0);
  // 多个手指iOS下会crash
  const [numberOfTouches, setNumberOfTouches] = React.useState(0);
  const swipeableRef = React.useRef<Swipeable>();
  const startX = React.useRef(0);
  const [isLeft, setIsLeft] = React.useState(false);
  const [scrollHorizontalEnabled, setScrollHorizontalEnabled] = React.useState(true);
  const tableWidth = React.useRef(ScreenWidth);
  // 排序
  const [selectSort, setSelectSort] = React.useState<TableColumn>();
  const [sortType, setSortType] = React.useState<SortType>(0);
  const [datas, setDatas] = React.useState(props.data);

  useEffect(() => {
    setSelectSort(undefined);
    setSortType(0);
    setDatas(props.data);
  },[props.data]);

  const onHorizontalScroll = (event: NativeSyntheticEvent<NativeScrollEvent>) => {
    const { x } = event.nativeEvent.contentOffset;
    // console.log('onScroll:',x);
    setOffsetX(x);
  };

  const onTouchStart = (event: GestureResponderEvent) => {
    setNumberOfTouches(event.nativeEvent.touches.length);
    startX.current = event.nativeEvent.touches[0].pageX;
  };

  const onTouchMove = (event: GestureResponderEvent) => {
    const touch = event.nativeEvent.touches[0];
    // console.log('onTouchMove:',touch.pageX);
    if(startX.current > touch.pageX) {
      setIsLeft(true);
    }else {
      setIsLeft(false);
    }
  };


  const onSortAction = (column: TableColumn) => {
    if(column.sorter) {
      let type: SortType = -1;
      if(selectSort?.key === column.key) {
        type = sortType === -1 ? 1 : sortType === 1 ? 0 : -1;
      }else {
        setSelectSort(column);
      }
      setSortType(type);
      if(type === 0) {
        setDatas(props.data);
      }else {
        const data = [...props.data];
        const newData = data.sort((a, b) => {
          const aVal = a[column.key];
          const bVal = b[column.key];
          if(type === 1) {
            return aVal > bVal ? 1 : -1;
          }else {
            return aVal > bVal ? -1 : 1;
          }
        });
        setDatas(newData);
      }
    }
  };

  const alignContent = (column: TableColumn) => {
    let justifyContent = {};
    if(column.align === 'center') {
      justifyContent = { justifyContent: 'center' };
    }else if(column.align === 'right'){
      justifyContent = { justifyContent: 'flex-end' };
    }
    return justifyContent;
  };
  const alignCellContent = (column: TableColumn) => {
    let alignItems = {};
    if(column.align === 'center') {
      alignItems = { alignItems: 'center' };
    }else if(column.align === 'right'){
      alignItems = { alignItems: 'flex-end' };
    }
    return alignItems;
  };

  const renderHeader = (column: TableColumn) => {
    if(column.renderHeader) {
      const justifyContent = alignContent(column);
      const header = column.renderHeader(column);
      return isValidElement(header) ?
        <View style={[styles.headerCell, justifyContent]}>{header}</View> :
        _renderHeader(column, header as string);
    }else {
      return _renderHeader(column, column.title);
    }
  };
  const _renderHeader = (column: TableColumn, text: string) => {
    const justifyContent = alignContent(column);
    return (
      <Pressable style={[styles.headerCell, justifyContent]}
        onPress={() =>onSortAction(column)}
      >
        <Text style={styles.headerCellText}>{text ? text : column.title}</Text>
        {
          column.sorter ?
            <View>
              {
                selectSort?.key === column.key ?
                  <Image style={sortType === 1 ? styles.headerSortImg : {}} source={sortType === 0 ? SortImg : SortHightImg}/>
                  : <Image source={SortImg}/>
              }
            </View>
            : null
        }
      </Pressable>
    );
  };

  const renderCell = (data: any, section: {row: number, col: number}, column: TableColumn) => {
    if(column.render) {
      const cell = column.render(data, section.row, section.col);
      return isValidElement(cell) ? cell :
        <Text style={styles.cellText}>{cell}</Text>;
    }else {
      return <Text style={styles.cellText}>{data[column.key]}</Text>;
    }
  };

  // 计算列宽
  const widthHandle = (column: TableColumn) => {
    const MaxColumns = props.maxColumns ?? 6;
    if(column.width) {
      if(typeof column.width === 'string' && column.width.endsWith('%')) {
        const percent = Number(column.width.replace('%', '')) / 100;
        const width = tableWidth.current * percent;
        return { width: width };
      }else if(column.width === 'auto') {
        const width = props.columns.length > MaxColumns ? tableWidth.current / MaxColumns : tableWidth.current /  props.columns.length;
        return { width: width };
      }
      return { width: column.width as DimensionValue };
    }else {
      const { totalFixWidth, number } = getFixTotalWidth();
      const diffWidth = tableWidth.current - totalFixWidth;
      const diffCount = props.columns.length - number;
      if(diffWidth > 0) {
        const width = Math.max(minRowWidth, diffWidth / diffCount);
        return { width: width };
      }else {
        const width = props.columns.length > MaxColumns ? tableWidth.current / MaxColumns : tableWidth.current /  props.columns.length;
        return { width: width };
      }
    }
  };

  // 计算已固定列宽
  const getFixTotalWidth = React.useCallback(() => {
    let totalFixWidth = 0;
    let number = 0;
    props.columns.forEach((column) => {
      if(column.width) {
        number++;
        totalFixWidth += column.width as number;
      }
    });
    return { totalFixWidth, number };
  }, [props.columns]);

  const onRowClick = (data: any, row: number) => {
    Log(`onRowClick${row}:`,data);
    props.onRowClick && props.onRowClick(data, row);
  };

  // 计算表格容器宽度
  const computeTableContentWidth = React.useCallback(() => {
    let width = 0;
    props.columns.forEach((column) => {
      const colWidth = widthHandle(column).width as number;
      width += colWidth;
    });
    return width;
  // eslint-disable-next-line react-hooks/exhaustive-deps
  },[props.columns]);

  const onTableLayout = (event: LayoutChangeEvent) => {
    const { width } = event.nativeEvent.layout;
    tableWidth.current = width - 2 * (props.space ?? 0);
    Log('onTableLayout:',tableWidth.current);
    const tableContentWidth = computeTableContentWidth();
    Log('tableContentWidth:', tableContentWidth);
    setScrollHorizontalEnabled(tableContentWidth - tableWidth.current > 2);
    props.onLayout && props.onLayout(event);
  };

  const leftSwipe = (data: any, row: number) => {
    if(props.leftSwipe) {
      return props.leftSwipe(data, row);
    }else {
      const onSwipeAction = () => {
        Log(`onSwipeAction${row}:`,data);
        props.onSwipeAction && props.onSwipeAction(data, row);
      };
      return [
        {
          text: <Text style={styles.swipeText}>{props.swipeText}</Text>,
          onPress: onSwipeAction,
          backgroundColor: 'rgba(0,0,0,0.1)',
        },
      ];
    }
  };

  const enabled = React.useMemo(() => {
    const enabled = offsetX <= 0 && numberOfTouches === 1 && !isLeft;
    Log('enabled:',enabled);
    return enabled;
  }, [numberOfTouches, offsetX, isLeft]);

  return (
    <View style={[styles.table, props.style]} onLayout={onTableLayout}>
      <ScrollView
        horizontal={true}
        scrollEnabled={scrollHorizontalEnabled}
        nestedScrollEnabled={true}
        showsHorizontalScrollIndicator={false}
        onScroll={onHorizontalScroll}
        onTouchStart={onTouchStart}
        onTouchMove={onTouchMove}
      >
        <View style={[]}>
          <View style={[styles.tableHeader, { marginHorizontal: props.space }]}>
            {
              props.columns.map((column, idx) => (
                <View key={`${column.key}_${idx}`}
                  style={[styles.headerRow, { ...widthHandle(column), height: props.headerHeight }]}
                >
                  { renderHeader(column) }
                </View>
              ))
            }
          </View>
          {
            datas && datas.length > 0 ?
              <ScrollView
                nestedScrollEnabled={true}
                scrollEnabled={false}
                showsVerticalScrollIndicator={false}
              >
                <View style={styles.tableBody} >
                  {
                    datas.map((data, row) =>{
                      return (
                        <SwipeAction key={`${row}`}
                          closeOnTouchOutside
                          left={leftSwipe(data, row)}
                          enabled={ props.isSwipeSupport && enabled }
                          onSwipeableWillOpen={()=> {
                            if(swipeableRef.current) {
                              swipeableRef.current.close();
                            }
                          }}
                          onSwipeableOpen={(_, ref) => {
                            swipeableRef.current = ref;
                          }}
                          onSwipeableClose={(_, ref) => {
                            if(swipeableRef.current === ref) {
                              swipeableRef.current = undefined;
                            }
                          }}
                        >
                          <Pressable key={`${row}`}
                            style={[styles.tableRow, { marginHorizontal: props.space }]}
                            onPress={()=>onRowClick(data, row)}
                          >
                            {
                              props.columns.map((column, col) => {
                                const alignItems = alignCellContent(column);
                                return (
                                  <View key={`${row}_${col}`}
                                    style={[
                                      styles.tableCell,
                                      alignItems,
                                      {
                                        ...widthHandle(column),
                                        height: props.rowHeight,
                                      },
                                    ]}
                                  >
                                    { renderCell(data, { row, col }, column) }
                                  </View>
                                );
                              })
                            }
                          </Pressable>
                        </SwipeAction>
                      );
                    })
                  }
                </View>
              </ScrollView> :
              <View style={{ marginTop: 50 }}/>
          }
        </View>
      </ScrollView>
      {
        scrollHorizontalEnabled &&
        <LinearGradient
          colors={['rgba(233, 232, 232, 0.3)', 'rgba(233, 232, 232, 1.0)']}
          start={{ x: 0, y: 0 }}
          end={{ x:1, y: 0 }}
          style={[styles.gradientStyle, { width: props.space }]}
        />
      }
    </View>
  );
};

const styles = StyleSheet.create({
  table: {
  },
  tableHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  headerRow: {
    marginHorizontal: 0.5,
    height: 40,
    justifyContent: 'center',
  },
  headerCell: {
    height:'100%',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-start',
    // backgroundColor: 'red',
  },
  headerSortImg: {
    transform: [{ rotate: '180deg' }],
  },
  headerCellText: {
    // textAlign: 'center',
    fontSize: 10,
    color: '#999',
    fontWeight: 400,
  },
  tableBody: {
    flexDirection: 'column',
  },
  tableRow: {
    flexDirection: 'row',
    borderTopColor: '#D7D9DE',
    borderTopWidth: 0.5,
  },
  tableCell: {
    height: 50,
    justifyContent: 'center',
    marginHorizontal: 0.5,
    // backgroundColor: 'yellow',
  },
  cellText: {
    // textAlign: 'center',
    color: '#999',
    fontSize: 12,
    fontWeight: 600,
  },
  swipeText: {
    color: '#000',
    fontSize: 12,
    fontWeight: 600,
    marginHorizontal: 15,
  },
  gradientStyle: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    right: 0,
  },
});

export default React.memo(Table);
