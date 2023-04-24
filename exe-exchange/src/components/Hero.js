import {Link} from 'react-router-dom'
import heroImage from '../assets/Layer 2.png'

export default function Hero() {
  return (
    <div className='hero'>
        <div className='hero-left'>
        <h1 className='heading'>
            Exchange Energy Effeciently
        </h1>
        <p>A better and unique way to exchange energy for a better future</p>
        <Link to='/trade'><button className='metamask-connect heroButton'>Trade Now</button></Link>
        </div>
        <img className='heroImage' src={heroImage} alt="" />
    </div>
  )
}
