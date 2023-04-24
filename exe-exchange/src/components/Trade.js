import {useState} from 'react'
import '../App.css'
import Navbar from './Navbar'

const positionData = [
    {
        direction: 'Buy',
        size: '6.77',
        price: '10',
        key:1
    },
    {
        direction: 'Sell',
        size: '5.32',
        price: '100',
        key:2
    },
    {
        direction: 'Buy',
        size: '10.54',
        price: '8',
        key:3
    },
    {
        direction: 'Sell',
        size: '3.12',
        price: '6',
        key:4
    },
]

const balanceInfo = {
    exe: '100',
    nextexe: '5',
    usdc: '100'
}


export default function Trade() {

    const [selected1, setSelected1] = useState(false)
    const [selected2, setSelected2] = useState(true)

    const handleSelected1 = () => {
        setSelected1(value => !value)
    }
    const handleSelected2 = () => {
        setSelected2(value => !value)
    }

  return (
    <>
    <Navbar />
    <div className='trade'>
        <div className='tradeBlock'>
            <h2 className='heading2'>Trade</h2>
            <div className='selectorBlock'>
                <button onClick={handleSelected1} className={'selector selectorLeft' + (selected1 ? ' selected' : '')}>
                    Buy EXE from USDC
                </button>
                <button onClick={handleSelected1} className={'selector selectorRight' + ((!selected1 ? ' selected' : ''))}>
                    Sell EXE for USDC
                </button>
            </div>
            <div className='selectorBlock'>
                <button onClick={handleSelected2} className={'selector selectorLeft' + ((selected2 ? ' selected' : ''))}>
                    Maker (Limit)
                </button>
                <button onClick={handleSelected2} className={'selector selectorRight' + ((!selected2 ? ' selected' : ''))}>
                    Taker (Market)
                </button>
            </div>
            <p style ={{margin: '20px 0'}}>Current Price : <span style={{color: '#5fbf80', fontWeight: 600}}>$30.00</span> </p>
            <input type="number" name="amount" className='input inputAmount' placeholder='Enter Amount' min='1'/>
            {selected1 && <input type="number" name="price" className='input inputPrice' placeholder='Enter Price' min={'1'}/>}
            <p style ={{margin: '20px 0'}}>Output : <span style={{color: '#5fbf80', fontWeight: 600}}>$30.00</span></p>
            <button className='metamask-connect heroButton'>Swap</button>
        </div>
        <div className='tradeBlock tradeBlock2'>
            <h2 className='heading2'>Your Positions</h2>
                {positionData.map((item) => (<div key={item.key} className='infoBlock'>
                    <span className='infoItem'>{item.direction}</span>
                    <span className='infoItem'>Size: {item.size}</span>
                    <span className='infoItem'>Price: {item.price}</span>
                    <button className='endButton'>end</button>
                </div>))}
            </div>
        <div className='tradeBlock3'>
        <div className='selectorBlock3'>
                <h2 className='heading2'>
                    Your Balances
                </h2>
                <h3 className='heading3'>EXE <span className='spacing'>{balanceInfo.exe}</span></h3>
                <h3 className='heading3'>EXE Gain <span>{balanceInfo.nextexe}</span></h3>
                <h3 className='heading3'>EXE <span>{balanceInfo.usdc}</span></h3>
            </div>
        </div>
    </div></>
  )
}
