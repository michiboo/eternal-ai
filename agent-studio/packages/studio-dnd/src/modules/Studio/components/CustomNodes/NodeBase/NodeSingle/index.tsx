import { useMemo } from 'react';

import Package from '../../../DnD/Package';
import Product from '../../../DnD/Product';
import LegoRender from '../LegoRender';
import NodeBaseConnection from '../NodeBaseConnection';
import NodeBaseWrapper from '../NodeBaseWrapper';
import { NodeBaseProps } from '../types';

import useStudioCategoryStore from '@/modules/Studio/stores/useStudioCategoryStore';
import { StudioCategoryOptionMapValue } from '@/modules/Studio/types/category';
import { DraggableData } from '@/modules/Studio/types/dnd';

import './NodeSingle.scss';

type Props = NodeBaseProps;

const NodeSingle = ({ data }: Props) => {
  const categoryMap = useStudioCategoryStore((state) => state.categoryMap);
  const categoryOptionMap = useStudioCategoryStore((state) => state.categoryOptionMap);

  const idx = data.metadata.idx;
  const option: StudioCategoryOptionMapValue | undefined = categoryOptionMap[idx];
  const category = Object.values(categoryMap).find((category) => category.options.some((option) => option.idx === idx));
  const schemaData = option?.data;

  const productData: Omit<DraggableData, 'type'> = useMemo(
    () => ({ optionKey: option?.idx, belongsTo: data.id, categoryKey: category?.idx }),
    [data.id, option?.idx, category?.idx],
  );

  return (
    <NodeBaseWrapper data={data} id={data.id} option={option}>
      <div className="node-base">
        <div className="node-base__single">
          <Product id={data.id} data={productData}>
            <LegoRender
              background={option?.color}
              icon={option?.icon}
              title={option?.title}
              id={data.id}
              schemaData={schemaData}
              idx={option?.idx}
              render={option?.customizeRenderOnBoard}
            />
          </Product>
        </div>

        <Package id={data.id} data={productData} />
        <NodeBaseConnection />
      </div>
    </NodeBaseWrapper>
  );
};

export default NodeSingle;
